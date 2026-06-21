# Instalar NVIDIA Container Toolkit

Prueba la instalación del driver de NVIDIA
```bash
nvidia-smi
```

Debería aparecer el modelo de GPU con el que cuenta la computadora, si no aparece se requiere la instalación de dicho driver antes de continuar con este tutorial.

Instalación NVIDIA Container Toolkit

```bash
sudo apt-get update

sudo apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  gnupg2
```

Agregar repositorio NVIDIA:
```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

Instalar
```bash
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

Configurar Docker para NVIDIA
```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

Verificar la configuración del runtime NVIDIA
```bash
cat /etc/docker/daemon.json
```

Se debería ver algo similar a esto:
```json
{
  "runtimes": {
    "nvidia": {
      "args": [],
      "path": "nvidia-container-runtime"
    }
  }
}
```

Test de la GPU en un contenedor Docker
```bash
docker run --rm --gpus all nvidia/cuda:12.5.0-base-ubuntu22.04 nvidia-smi
```
Si a la salida se observa que se reconoce la GPU la configuración ha sido un éxito