# Ollama local con Docker y NVIDIA

Este folder reúne una guía corta para dejar [Ollama](https://ollama.com/) corriendo en local con Docker y, además de aceleración con un GPU NVIDIA.

## Tutoriales 📌

1. [Instalar Docker](./install_config_docker.md)
2. [NVIDIA Container Toolkit](./install_nvidia_container_toolkit.md)
3. [Configurar el contenedor Docker que correrá Ollama](./setup_ollama_docker.md)

El orden recomendado es exactamente ese:

1. `install_config_docker.md` instala Docker y deja habilitado `docker compose`.
2. `install_nvidia_container_toolkit.md` agrega el runtime de NVIDIA para que los contenedores puedan usar la GPU.
3. `setup_ollama_docker.md` levanta Ollama, descarga modelos, prueba que respondan y deja una configuración opcional para Continue en VSCode.

Además se incluye el archivo [`compose.ollama.yaml`](./compose.ollama.yaml), que es la base para levantar el contenedor `ollama` escuchando en `127.0.0.1:11434` y guardar los modelos en un volumen persistente.

## Qué cubre esta guía

- Instalación limpia de Docker desde el repositorio oficial.
- Habilitación del runtime de NVIDIA para contenedores.
- Levantar Ollama con `docker compose`.
- Descargar y probar modelos como `qwen2.5-coder`.
- Integración opcional con Continue en VSCode.

Si Docker ya está instalado y funcionando, puedes saltarte al tutorial que te falte. Si no usarás GPU, también puedes omitir el apartado de NVIDIA y levantar Ollama solo con CPU.
