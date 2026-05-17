# Ubuntu 24.04 Setup

## 1. Descripción

Este directorio contiene scripts de post-instalación para Ubuntu 24.04 LTS orientados a preparar una estación de trabajo para desarrollo, administración de sistemas y trabajo técnico general.

La organización separa la instalación por origen de paquetes para facilitar la ejecución:

- `apt` para paquetes del sistema y herramientas base.
- `snap` para software publicado en el ecosistema Snap.
- `flatpak` para aplicaciones distribuidas mediante Flathub.

## 2. Archivos incluidos

| Archivo | Propósito |
| --- | --- |
| `apt_ubuntu24.04.sh` | Instala paquetes principales del sistema mediante `apt`. |
| `snap_ubuntu24.04.sh` | Instala aplicaciones publicadas como paquetes `snap`. |
| `flatpak_ubuntu24.04.sh` | Instala aplicaciones distribuidas mediante `flatpak`. |

## 3. Motivación y enfoque

Estos scripts son, básicamente, mi punto de partida para dejar una instalación de Ubuntu 24.04 lista para trabajar. Este script es la evolución desde que empecé con Ubuntu 10.04. Aquí se incorporan las utilidades del sistema, herramientas de desarrollo y varias apps que suelo usar, cada una instalada por el más óptimo, aunque sigo prefiriendo `apt`.

La separación propuesta en tres scripts distintos me permite:

- ejecutar solo lo necesario según el caso de uso.
- mantener un orden lógico de instalación.
- evitar mezclar canales de instalación.
- facilitar la revisión y mantenimiento de cada sección.

## 4. Uso

Cambiar al directorio `post_installation`, otorgar permisos de ejecución a los scripts y ejecutarlos en el orden requerido:

```bash
cd ubuntu_2404_setup/post_installation
chmod +x apt_ubuntu24.04.sh
chmod +x flatpak_ubuntu24.04.sh
chmod +x snap_ubuntu24.04.sh

sudo ./apt_ubuntu24.04.sh
sudo ./flatpak_ubuntu24.04.sh
sudo ./snap_ubuntu24.04.sh
```

**Nota:** aunque en `apt_ubuntu24.04.sh` se incluyen la instalación de Docker y python; en la raíz de este proyecto se encuentran scripts específicos para configurar entornos de desarrollo con Docker, TensorFlow, PyTorch y Python virtual environments, que pueden ser ejecutados posteriormente según las necesidades.

## Adicionales

Al 17 de mayo se probó Ubuntu 26.04, pero se encontraron problemas con la instalación de Docker y TensorFlow, por lo que se decidió mantener esta guía enfocada en Ubuntu 24.04 LTS.
---
