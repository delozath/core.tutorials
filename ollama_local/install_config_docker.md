# Instalar Docker

Eliminar paquetes conflictivos del repositorio apt

```bash
sudo apt update

sudo apt remove -y \
  docker.io \
  docker-compose \
  docker-compose-v2 \
  docker-doc \
  podman-docker || true
```

Instalar herramientas para gestionar el repositorio oficial de Docker
```bash
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Crea el repositorio
```bash
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Instala Docker y plugin actualizados
```bash
sudo apt update

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

**Opcional** Configurar una ruta alternativa para el almacenamiento de las imágenes Docker que se instalan

Editar el `daemon.json` y agregar el atributo `"data-root": "/newpath/docker"`

```bash
sudo nano /etc/docker/daemon.json
```

El archivo se verá similar a esto:

```json
{
    "data-root": "/newpath/docker",
    "iptables": false,
}

```

Inicializar docker:
```bash
sudo systemctl enable --now docker
```


Agregar usuario al grupo docker:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

Test de funcionamiento:
```bash
docker version
docker compose version
docker run --rm hello-world
```
