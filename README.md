# core.learning

📚 `core.learning` es el repositorio donde concentro el código de las clases que he impartido, junto con herramientas, materiales y elementos adicionales de apoyo para la docencia. Está pensado como una plataforma para organizar procesos académicos, automatizar tareas recurrentes (burocracia pura) y mantener en un solo todo el código de los cursos.

En términos prácticos, este proyecto funciona como un espacio de desarrollo para soluciones educativas propias, pero que creo que pueden ser de utilidad para otros docentes. A continuación una breve descripción de cada parte del:

## ✍️ App CLI + Hydra `syllabus`

`syllabus` es una aplicación CLI orientada a la generación de programas de curso a partir de configuración declarativa en YAML. Se ha implementado en una arquitectura Hexagonal para permitir una extensibilidad y mantenibilidad óptimas. Su propósito es automatizar la elaboración de la planeación de un curso, en principio pensado para las UEA de UAM-Iztapalapa, pero que puede adaptarse a otros contextos. Se enfoca en centralizar la información académica del curso y reducir el trabajo manual necesario en la planeación, para reenfocar el trabajo docente en aspectos de adecuaciones y actualizaciones de los cursos, evitando el fenómeno del mismo contenido repetido.

Actualmente, `syllabus` permite definir cursos e instituciones mediante Hydra, consultar información desde CSV o SQLite, estructurar temario, sesiones y calendario académico, y además renderizar la salida final como un archivo `.tex` listo para compilar. Su arquitectura modular también facilita extender el flujo hacia nuevas tareas académicas, nuevas fuentes de datos y procesos de publicación en otros formatos.

🔗 Página principal de la app: [apps/syllabus/](./apps/syllabus/)
