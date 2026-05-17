#!/bin/bash

# Verificar si se pasó el nombre del proyecto
if [ -z "$1" ]; then
    echo "Error: Debes proporcionar el nombre del proyecto."
    echo "Uso: ./init_project.sh nombre_del_proyecto"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="./$PROJECT_NAME"
ENV_DIR="./env"

#if [ ! -d "$ENV_DIR" ]; then
#    echo "Error: Este script debe ejecutarse desde la raiz de ml_projects/."
#    echo "No se encontró el directorio compartido: $ENV_DIR"
#    exit 1
#fi

if [ "$PROJECT_NAME" = "env" ]; then
    echo "Error: 'env' es un nombre reservado dentro de ml_projects/."
    exit 1
fi

# Validar si el proyecto ya existe para evitar sobrescrituras accidentales
if [ -d "$PROJECT_DIR" ]; then
    echo "Error de Seguridad: El directorio del proyecto '$PROJECT_NAME' ya existe en esta ruta ($PROJECT_DIR)."
    echo "Cancelando operación para proteger tu código existente."
    exit 1
fi

echo "Iniciando creación de la estructura base para el proyecto: $PROJECT_NAME"

# Crear árbol de directorios estructurado según la convención de ml_projects/
mkdir -p "$PROJECT_DIR/conf/model"
mkdir -p "$PROJECT_DIR/conf/dataset"
mkdir -p "$PROJECT_DIR/src"
mkdir -p "$PROJECT_DIR/tests"
mkdir -p "$PROJECT_DIR/train"
mkdir -p "$PROJECT_DIR/test"
mkdir -p "$PROJECT_DIR/models"
mkdir -p "$PROJECT_DIR/mlruns"

# Crear archivos base esenciales de Python (Módulos)
touch "$PROJECT_DIR/src/__init__.py"
touch "$PROJECT_DIR/tests/__init__.py"

# Generar entrypoint base para Hydra usando la nueva ruta de configuración
cat << 'INNER_EOF' > "$PROJECT_DIR/src/train_entry.py"
import hydra
from omegaconf import DictConfig

@hydra.main(version_base=None, config_path="../conf", config_name="config")
def main(cfg: DictConfig) -> None:
    print("Proyecto inicializado correctamente")
    print(f"Modelo: {cfg.model.name}")
    print(f"Dataset: {cfg.dataset.name}")

if __name__ == "__main__":
    main()
INNER_EOF

# Generar la configuración base de Hydra
cat << 'INNER_EOF' > "$PROJECT_DIR/conf/config.yaml"
defaults:
  - model: default
  - dataset: local
  - _self_

project_name: default_project
seed: 42
epochs: 10
INNER_EOF

cat << 'INNER_EOF' > "$PROJECT_DIR/conf/model/default.yaml"
name: baseline_model
framework: pytorch
INNER_EOF

cat << 'INNER_EOF' > "$PROJECT_DIR/conf/dataset/local.yaml"
name: local_dataset
train_path: ./train
test_path: ./test
models_path: ./models
mlruns_path: ./mlruns
INNER_EOF

cat << 'INNER_EOF' > "$PROJECT_DIR/tests/test_sample.py"
def test_sample() -> None:
    assert True
INNER_EOF

sed -i "s/default_project/$PROJECT_NAME/" "$PROJECT_DIR/conf/config.yaml"

echo "Estructura de '$PROJECT_NAME' creada con éxito."
echo "Ubicación: $PROJECT_DIR"
echo "Siguientes pasos:"
echo "  cd $PROJECT_NAME"
echo "  docker compose -f ../env/docker-compose.yml up -d"
