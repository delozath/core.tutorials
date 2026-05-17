# Ubuntu 24.04 Setup

Este folder contiene tres guías para la instalación de un entorno de trabajo en Ubuntu 24.04 LTS.


## Orden recomendado

### 1. Base del sistema: post-instalación de Ubuntu

El folder [`post_installation/`](./post_installation/) contiene el punto de partida de toda la configuración. Ahí se agrupan scripts para instalar software mediante `apt`, `snap` y `flatpak`. Para mantener una instalación más clara.

README.md: [`post_installation/README.md`](./post_installation/README.md)

---

### 2. Entorno general de Python no GPU

El folder [`python_venv_general/`](./python_venv_general/) propone un entorno virtual orientado a ciencia de datos, machine learning, visualización y trabajo técnico general con Python, sin pensar en una configuración de GPU. El enfoque está centrado en `uv` para la gestión del entorno y en una base cómoda para experimentar, desarrollar.

Este proyecto permite tener un sistema estable con un espacio de trabajo reproducible y pensado para la mayoría de tareas que no requieren contenedores ni aceleración CUDA.

README.md: [`python_venv_general/README.md`](./python_venv_general/README.md)

---

### 3. Entorno especializado para TensorFlow, PyTorch y CUDA con Docker

El folder [`docker_tf_torch_nvidia/`](./docker_tf_torch_nvidia/) está pensado para el escenario más específico: proyectos de deep learning que sí requieren estabilidad en el sistema de instalación y dependencias, soporte de GPU NVIDIA y una organización más estricta para entrenamiento, pruebas, modelos y artefactos. Aquí se describe la instalación del `nvidia-container-toolkit`, la configuración de Docker para GPU, la construcción de imágenes base para TensorFlow y PyTorch, y una estructura reutilizable de proyectos.

README.md: [`docker_tf_torch_nvidia/README.md`](./docker_tf_torch_nvidia/README.md)

## Cómo elegir la guía adecuada

- Si se parte de una instalación limpia de Ubuntu, conviene comenzar por [`post_installation`](./post_installation/README.md).
- Si se necesita un entorno general de Python para análisis, automatización o experimentación sin GPU, la guía adecuada es [`python_venv_general`](./python_venv_general/README.md).
- Si el trabajo requiere CUDA, contenedores y frameworks de deep learning, corresponde seguir [`docker_tf_torch_nvidia`](./docker_tf_torch_nvidia/README.md).
