# core.tutorial

📚 `core.tutorial` es el repositorio donde concentro tutoriales, materiales y código asociado a las clases que he impartido. Está pensado como un espacio para documentar procesos técnicos que uso en docencia y dejar flujos de trabajo reproducibles para montar, adaptar o reutilizar distintos recursos de curso.

En términos prácticos, este proyecto funciona como una colección de tutoriales y desarrollos educativos propios que creo que también pueden ser de utilidad para otros docentes. A continuación una breve descripción de cada parte del repositorio:

## ✍️ App CLI + Hydra `syllabus`
**Warning:** Este proyecto está lo migraré proximamente a un repo más ad hoc

`syllabus` es una aplicación CLI orientada a la generación de programas de curso a partir de configuración declarativa en YAML. Se ha implementado en una arquitectura Hexagonal para permitir una extensibilidad y mantenibilidad óptimas. Su propósito es automatizar la elaboración de la planeación de un curso, en principio pensado para las UEA de UAM-Iztapalapa, pero que puede adaptarse a otros contextos. Se enfoca en centralizar la información académica del curso y reducir el trabajo manual necesario en la planeación, para reenfocar el trabajo docente en aspectos de adecuaciones y actualizaciones de los cursos, evitando el fenómeno del mismo contenido repetido.

Actualmente, `syllabus` permite definir cursos e instituciones mediante Hydra, consultar información desde CSV o SQLite, estructurar temario, sesiones y calendario académico, y además renderizar la salida final como un archivo `.tex` listo para compilar. Su arquitectura modular también facilita extender el flujo hacia nuevas tareas académicas, nuevas fuentes de datos y procesos de publicación en otros formatos.

🔗 Referencias:

- Proyecto: [apps/syllabus/](./apps/syllabus/)
- README: [apps/syllabus/README.md](./apps/syllabus/README.md)

## 🐧 Guías y scripts `ubuntu_2404_setup`

`ubuntu_2404_setup` concentra una serie de guías y scripts para dejar listo un entorno de trabajo sobre Ubuntu 24.04 LTS. Aquí la lógica es menos la de una aplicación formal y más la de un conjunto de recetas reproducibles para instalación, configuración base y preparación de ambientes de desarrollo. Me sirve como punto de partida para montar estaciones de trabajo de forma rápida y ordenada, separando el caso general del caso más especializado para GPU.

En este bloque del repositorio se separan tres escenarios. El primero corresponde a la post-instalación del sistema, con scripts organizados por origen de paquetes (`apt`, `snap` y `flatpak`). El segundo propone un entorno virtual general de Python apoyado en `uv`, pensado para análisis, automatización, visualización y trabajo técnico sin depender de GPU. El tercero está orientado a un entorno más estricto para TensorFlow, PyTorch y CUDA mediante Docker, con una estructura reutilizable para proyectos de deep learning y soporte para GPU NVIDIA.

🔗 Referencias:

- Proyecto principal: [ubuntu_2404_setup/](./ubuntu_2404_setup/)
- README general: [ubuntu_2404_setup/README.md](./ubuntu_2404_setup/README.md)
- Post-instalación de Ubuntu 24.04: [ubuntu_2404_setup/post_installation/](./ubuntu_2404_setup/post_installation/) | [README](./ubuntu_2404_setup/post_installation/README.md)
- Entorno virtual general de Python: [ubuntu_2404_setup/python_venv_general/](./ubuntu_2404_setup/python_venv_general/) | [README](./ubuntu_2404_setup/python_venv_general/README.md)
- TensorFlow + PyTorch + CUDA con Docker: [ubuntu_2404_setup/docker_tf_torch_nvidia/](./ubuntu_2404_setup/docker_tf_torch_nvidia/) | [README](./ubuntu_2404_setup/docker_tf_torch_nvidia/README.md)

## 🤖 Ollama local con Docker y NVIDIA `ollama_local`

`ollama_local` reúne una guía breve para desplegar Ollama en local dentro de un contenedor Docker, con soporte para aceleración mediante GPU NVIDIA cuando el equipo lo permite. La idea es dejar un entorno reproducible para correr modelos en la propia máquina, mantener persistencia de modelos y exponer el servicio localmente para consumirlo desde otras herramientas.

Este bloque del repositorio organiza el proceso en una secuencia corta de tutoriales: instalación y configuración de Docker, habilitación del runtime de NVIDIA para contenedores y puesta en marcha del servicio de Ollama con `docker compose`. Además, incluye una configuración base para descargar modelos, probar que responden correctamente y, de forma opcional, integrarlos con Continue en VSCode.

🔗 Referencias:

- Proyecto: [ollama_local/](./ollama_local/)
- README: [ollama_local/README.md](./ollama_local/README.md)
- Instalar Docker: [ollama_local/install_config_docker.md](./ollama_local/install_config_docker.md)
- NVIDIA Container Toolkit: [ollama_local/install_nvidia_container_toolkit.md](./ollama_local/install_nvidia_container_toolkit.md)
- Configurar Ollama con Docker: [ollama_local/setup_ollama_docker.md](./ollama_local/setup_ollama_docker.md)
