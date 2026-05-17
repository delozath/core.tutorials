# 🚀 Setup TensorFlow y PyTorch + CUDA en Ubuntu 24.04 LTS

Guía paso a paso para instalar TensorFlow y PyTorch con soporte CUDA en Ubuntu 24.04 LTS, optimizando el rendimiento en GPUs NVIDIA.

---

## ✅ Requisitos previos

- GPU NVIDIA compatible con CUDA.
- Controladores NVIDIA actualizados.
- CUDA Toolkit 12.0 o superior.
- Python 3.8 o superior.

---

## ⚙️ Instalación de CUDA Toolkit + Docker NVIDIA Container Toolkit

1. Instalar los controladores NVIDIA (si no están instalados)

Verificar que la GPU NVIDIA es detectada por el sistema:

```bash
lspci | grep -i nvidia
nvidia-smi
```

Si `nvidia-smi` indica una GPU el driver ya está instalado.

Si no funciona la forma más sencilla es usar el driver recomendado por `ubuntu-drivers`:

```bash
sudo apt update
ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
sudo reboot
```

Verificar que el driver se instaló correctamente:

```bash
nvidia-smi
```

2. Instalar prerequisitos, añadir repo oficial libnvidia-container, instalar nvidia-container-toolkit, configurar Docker con nvidia-ctk y reiniciar Docker.

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends ca-certificates curl gnupg2

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update

sudo apt-get install -y nvidia-container-toolkit
```

3. Configurar Docker para usar el runtime de NVIDIA:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

---

## 🐳 Configuración Docker

En mi caso prefiero usar Docker para aislar el entorno de desarrollo y evitar conflictos de dependencias, si se actualizan drivers, bibliotecas o frameworks; con Docker, el entorno de desarrollo se mantiene estable y reproducible.

**Nota:** En el script `apt_ubuntu24.04.sh` se incluye la instalación de Docker.

### 💾 Reubicación del Almacenamiento de Docker (Data-Root)

Las imágenes de Deep Learning con soporte CUDA pueden ocupar entre 5 GB y 12 GB cada una. Para evitar saturar el disco principal (`/`), reubicaremos el directorio raíz de Docker hacia un medio de almacenamiento secundario o externo.

1. Detener los servicios de Docker

```bash
sudo systemctl stop docker
sudo systemctl stop docker.socket

```

2. Crear el nuevo directorio destino

Reemplaza `/ruta/a/tu/almacenamiento_externo` por el punto de montaje real de tu unidad secundaria.

```bash
sudo mkdir -p /ruta/a/tu/almacenamiento_externo/docker
```

2a. Migrar datos existentes (Opcional)

Si ya cuentas con contenedores o imágenes que deseas preservar:

```bash
sudo rsync -aqxP /var/lib/docker/ /ruta/a/tu/almacenamiento_externo/docker
```

3. Modificar la configuración del daemon de Docker

Edita o crea el archivo de configuración:

```bash
sudo nano /etc/docker/daemon.json
```

4. Agrega la directiva data-root apuntando a la ruta genérica:

```json
{
  "data-root": "/ruta/a/tu/almacenamiento_externo/docker"
  "iptables": false
}
```

**Nota: ** se recomienda deshabilitar `iptables` para evitar conflictos con firewalls personalizados, especialmente en entornos de desarrollo o servidores.

5. Reiniciar y verificar el servicio

Respalda la carpeta antigua de forma preventiva, reinicia el servicio y comprueba la ruta:

```bash
sudo mv /var/lib/docker /var/lib/docker.old
sudo systemctl start docker
sudo usermod -aG docker $USER
```

6. Verificar que Docker apunte al nuevo almacenamiento

```bash
sudo docker info | grep "Docker Root Dir"
```

Si la salida confirma la nueva ruta, puedes remover el respaldo con `sudo rm -rf /var/lib/docker.old`.

---

## 🗂️ Estructura de los Proyectos TensorFlow y PyTorch

Para mantener un entorno organizado y facilitar el desarrollo, se recomienda estructurar los proyectos de la siguiente manera:

```text
ml_projects/
├── env/
│   ├── docker-compose.yml        # Orquestación compartida para los proyectos
│   ├── Dockerfile.pytorch        # Imagen base reutilizable para proyectos PyTorch
│   └── Dockerfile.tensorflow     # Imagen base reutilizable para proyectos TensorFlow
├── project_1/
│   ├── conf/                    # ⚙️ Centralización de configuraciones (Hydra)
│   │   ├── config.yaml          # Configuración global base
│   │   ├── model/               # Configuraciones específicas de arquitecturas
│   │   │   └── default.yaml
│   │   └── dataset/             # Mapeo de rutas y parámetros de datos
│   │       └── local.yaml
│   ├── src/                     # 📝 Código fuente (Dominio, Puertos, Adaptadores)
│   │   ├── __init__.py
│   │   └── train_entry.py       # Punto de entrada principal (Hydra Entrypoint)
│   ├── tests/                   # 🧪 Pruebas unitarias y de integración (Pytest)
│   │   ├── __init__.py
│   │   └── test_sample.py
│   ├── train/                   # 💾 Volumen persistente: Datos de entrenamiento
│   ├── test/                    # 💾 Volumen persistente: Datos de validación/test
│   ├── models/                  # 💾 Volumen persistente: Pesos y artefactos (.pt, .h5, .onnx)
│   └── mlruns/                  # 📊 Volumen persistente: Servidor local de MLflow
└── project_2/
    ├── conf/
    ├── src/
    ├── tests/
    ├── train/
    ├── test/
    ├── models/
    └── mlruns/
```

En caso de requerir entornos especificaciones de hardware diferentes, se pueden crear subcarpetas dentro de `env/` para cada proyecto, manteniendo la modularidad y reutilización de las imágenes base.

El script `init_project.sh` se encarga de crear esta estructura de carpetas y archivos base para cada nuevo proyecto, asegurando una organización consistente.

```bash
sudo chmod +x init_project.sh
sh ./init_project.sh project_1
```

---

## 🧱 Imagenes base de Docker para TensorFlow y PyTorch

1. Crear `Dockerfile.tensorflow` con la imagen base oficial de TensorFlow con soporte CUDA. El archivo se encuentra en `env/Dockerfile.tensorflow` y se basa en `tensorflow/tensorflow:latest-gpu`.

2. Crear `Dockerfile.pytorch` con la imagen base oficial de PyTorch con soporte CUDA. El archivo se encuentra en `env/Dockerfile.pytorch` y se basa en `pytorch/pytorch:latest-cuda`.

3. Crear un archivo `docker-compose.yml` en la carpeta `env/` para orquestar ambos entornos de desarrollo, mapeando el directorio del proyecto actual a `/workspace` dentro de los contenedores y configurando el runtime de NVIDIA para acceso a GPU.

4. Para compilar las imágenes, navega a tu directorio central `env/` y ejecuta:

```bash
# Compilar entorno PyTorch
docker compose build --no-cache torch_gpu

# Compilar entorno TensorFlow (Catálogo NGC)
docker compose build --no-cache tf_gpu
```

---

## 🧪 Ejemplo

Encender contenedor TensorFlow o PyTorch para un proyecto:

```bash
PROJECT_DIR=$PWD docker compose -p dl_env -f ../env/docker-compose.yml up -d
```

`PROJECT_DIR=$PWD`, indica al Docker en donde montar los volúmenes persistentes enlazados a `/workspace` dentro del contenedor. El parámetro `-p dl_env` indica el identificador de ambiente (env) que se le dará a estos contenedores.

```bash
#ml_projects/
./init_project.sh tf_ejemplo
cd tf_ejemplo

```

### Prueba de TensorFlow

Ingresa al contenedor de TensorFlow:

```bash
docker exec -it dl_env-tf_gpu-1 /bin/bash
```

En el CLI del contenedor, ejecuta el siguiente comando para verificar que TensorFlow detecta la GPU:

```bash
python -c "import tensorflow as tf; print('TF Version:', tf.__version__); print('GPUs Core Detectadas:', tf.config.list_physical_devices('GPU'))"
```

Se verá algo como

```bash
GPUs Core Detectadas: [PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
```

### Prueba de PyTorch

Ingresa al contenedor de PyTorch:

```bash
docker exec -it dl_env-torch_gpu-1 /bin/bash
```

En el CLI del contenedor, ejecuta el siguiente comando para verificar que PyTorch detecta la GPU:

```bash
python -c "import torch; print('CUDA Activo en PyTorch:', torch.cuda.is_available()); print('GPU Detectada:', torch.cuda.get_device_name(0))"
```

Se verá algo como

```bash
CUDA Activo en PyTorch: True
GPU Detectada: NVIDIA Nombre y modelo de GPU
```

El script `train_entry.py` dentro de `src/` describe un ejemplo de entry point para entrenamiento con Hydra para TensorFlow. Se puede ejecutar el comando de entrenamiento con parámetros personalizados directamente desde el CLI del contenedor:

```bash
python src/train_entry.py epochs=3 batch_size=64 mixed_precision=false
```
