# core.learning

📚 `core.learning` es el repositorio donde concentro el código de las clases que he impartido, junto con herramientas, materiales y elementos adicionales de apoyo para la docencia. Está pensado como una plataforma para organizar procesos académicos, automatizar tareas recurrentes (burocracia pura) y mantener en un solo todo el código de los cursos.

En términos prácticos, este proyecto funciona como un espacio de desarrollo para soluciones educativas propias, pero que creo que pueden ser de utilidad para otros docentes. A continuación una breve descripción de cada parte del repositorio:

## ✍️ App CLI + Hydra `syllabus`

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
