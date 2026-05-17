import os
import pickle
import time
from pathlib import Path

import hydra
import numpy as np
import tensorflow as tf
from hydra.utils import to_absolute_path
from omegaconf import DictConfig
from tensorflow import keras
from tensorflow.keras import layers


def configure_runtime(use_mixed_precision: bool = True) -> None:
    print("TensorFlow:", tf.__version__)

    gpus = tf.config.list_physical_devices("GPU")
    print("GPUs detected:", gpus)

    if not gpus:
        print("WARNING: No GPU detected. Training will run on CPU.")
        return

    for gpu in gpus:
        tf.config.experimental.set_memory_growth(gpu, True)

    if use_mixed_precision:
        from tensorflow.keras import mixed_precision

        mixed_precision.set_global_policy("mixed_float16")
        print("Mixed precision enabled:", mixed_precision.global_policy())

    logical_gpus = tf.config.list_logical_devices("GPU")
    print("Logical GPUs:", logical_gpus)


def load_cifar_batch(batch_path: str):
    with open(batch_path, "rb") as fh:
        batch = pickle.load(fh, encoding="bytes")

    images = batch[b"data"].reshape(-1, 3, 32, 32).transpose(0, 2, 3, 1)
    labels = np.array(batch[b"labels"], dtype="int32")
    return images, labels


def load_cifar10_from_local(train_dir: str, test_dir: str):
    train_root = Path(train_dir)
    test_root = Path(test_dir)

    train_base_dir = train_root / "cifar-10-batches-py" if (train_root / "cifar-10-batches-py").is_dir() else train_root
    test_base_dir = test_root / "cifar-10-batches-py" if (test_root / "cifar-10-batches-py").is_dir() else test_root

    train_files = [train_base_dir / f"data_batch_{idx}" for idx in range(1, 6)]
    test_file = test_base_dir / "test_batch"

    x_train_parts = []
    y_train_parts = []

    for train_file in train_files:
        x_part, y_part = load_cifar_batch(str(train_file))
        x_train_parts.append(x_part)
        y_train_parts.append(y_part)

    x_test, y_test = load_cifar_batch(str(test_file))
    x_train = np.concatenate(x_train_parts, axis=0)
    y_train = np.concatenate(y_train_parts, axis=0)

    return x_train, y_train, x_test, y_test


def make_dataset(batch_size: int, train_dir: str, test_dir: str):
    x_train, y_train, x_test, y_test = load_cifar10_from_local(train_dir, test_dir)

    def preprocess_train(x, y):
        x = tf.cast(x, tf.float32) / 255.0
        x = tf.image.resize(x, [64, 64])
        x = tf.image.random_flip_left_right(x)
        x = tf.image.random_brightness(x, max_delta=0.08)
        x = tf.image.random_contrast(x, lower=0.9, upper=1.1)
        return x, y

    def preprocess_test(x, y):
        x = tf.cast(x, tf.float32) / 255.0
        x = tf.image.resize(x, [64, 64])
        return x, y

    train_ds = (
        tf.data.Dataset.from_tensor_slices((x_train, y_train))
        .shuffle(20_000)
        .map(preprocess_train, num_parallel_calls=tf.data.AUTOTUNE)
        .batch(batch_size)
        .prefetch(tf.data.AUTOTUNE)
    )

    test_ds = (
        tf.data.Dataset.from_tensor_slices((x_test, y_test))
        .map(preprocess_test, num_parallel_calls=tf.data.AUTOTUNE)
        .batch(batch_size)
        .prefetch(tf.data.AUTOTUNE)
    )

    return train_ds, test_ds, len(x_train)


def conv_block(x, filters: int):
    x = layers.Conv2D(filters, 3, padding="same", use_bias=False)(x)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)

    x = layers.Conv2D(filters, 3, padding="same", use_bias=False)(x)
    x = layers.BatchNormalization()(x)
    x = layers.Activation("relu")(x)

    x = layers.MaxPooling2D()(x)
    return x


def build_model() -> keras.Model:
    inputs = keras.Input(shape=(64, 64, 3))

    x = conv_block(inputs, 32)
    x = conv_block(x, 64)
    x = conv_block(x, 128)

    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.25)(x)
    outputs = layers.Dense(10, activation="softmax", dtype="float32")(x)

    model = keras.Model(inputs, outputs)
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=3e-4),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
        jit_compile=False,
    )
    return model


class ThroughputCallback(keras.callbacks.Callback):
    def __init__(self, batch_size: int, steps_per_epoch: int):
        super().__init__()
        self.batch_size = batch_size
        self.steps_per_epoch = steps_per_epoch
        self.start = 0.0

    def on_epoch_begin(self, epoch, logs=None):
        self.start = time.perf_counter()

    def on_epoch_end(self, epoch, logs=None):
        elapsed = time.perf_counter() - self.start
        images = self.batch_size * self.steps_per_epoch
        throughput = images / elapsed
        print(f"epoch_time_sec={elapsed:.2f} images_per_sec={throughput:.1f}")


@hydra.main(version_base=None, config_path="../conf", config_name="config")
def main(cfg: DictConfig) -> None:
    seed = int(cfg.get("seed", 42))
    epochs = int(cfg.get("epochs", 5))
    batch_size = int(cfg.get("batch_size", 128))
    use_mixed_precision = bool(cfg.get("mixed_precision", True))
    train_dir = to_absolute_path(cfg.dataset.train_path)
    test_dir = to_absolute_path(cfg.dataset.test_path)

    tf.keras.utils.set_random_seed(seed)
    configure_runtime(use_mixed_precision=use_mixed_precision)

    train_ds, test_ds, train_size = make_dataset(batch_size, train_dir, test_dir)
    model = build_model()
    model.summary()

    steps_per_epoch = train_size // batch_size

    print("\nStarting training...")
    total_start = time.perf_counter()

    history = model.fit(
        train_ds,
        validation_data=test_ds,
        epochs=epochs,
        callbacks=[
            ThroughputCallback(
                batch_size=batch_size,
                steps_per_epoch=steps_per_epoch,
            )
        ],
    )

    total_elapsed = time.perf_counter() - total_start

    models_dir = to_absolute_path(cfg.dataset.models_path)
    os.makedirs(models_dir, exist_ok=True)
    model_path = os.path.join(models_dir, f"{cfg.project_name}_cnn.keras")
    model.save(model_path)

    print("\nFinal metrics:")
    print("train_loss:", history.history["loss"][-1])
    print("train_accuracy:", history.history["accuracy"][-1])
    print("val_loss:", history.history["val_loss"][-1])
    print("val_accuracy:", history.history["val_accuracy"][-1])
    print(f"total_time_sec={total_elapsed:.2f}")
    print("model_saved_to:", model_path)


if __name__ == "__main__":
    main()
