#!/usr/bin/env bash

set -e

# ==============================================================================
# 0. Actualización inicial y utilerías mínimas para trabajar con APT y llaves
# ==============================================================================

sudo apt update

sudo apt install -y \
  ca-certificates \
  curl \
  wget \
  gpg \
  gnupg \
  apt-transport-https \
  software-properties-common \
  lsb-release

# ==============================================================================
# 1. Repositorios externos APT
# Se agregan solo los que conviene mantener desde su fuente oficial.
# ==============================================================================

# ------------------------------------------------------------------------------
# Visual Studio Code - repo oficial de Microsoft
# Se registra la llave en keyrings y luego la entrada del repositorio.
# ------------------------------------------------------------------------------

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null

echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# ------------------------------------------------------------------------------
# Docker CE - repo oficial de Docker
# Se deja activo para instalar la versión mantenida por Docker y no la de Ubuntu.
# ------------------------------------------------------------------------------

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt upgrade -y

# ==============================================================================
# 2. Herramientas esenciales del sistema
# Base para compilar, inspeccionar, mover archivos y trabajar cómodo en terminal.
# ==============================================================================

sudo apt install -y \
  build-essential \
  pkg-config \
  dkms \
  make \
  cmake \
  ninja-build \
  meson \
  autoconf \
  automake \
  libtool \
  git \
  git-lfs \
  curl \
  wget \
  rsync \
  unzip \
  zip \
  p7zip-full \
  unrar \
  tar \
  xz-utils \
  exfatprogs \
  htop \
  btop \
  tree \
  ncdu \
  tmux \
  screen \
  jq \
  ripgrep \
  fd-find \
  bat \
  fzf \
  silversearcher-ag \
  dconf-editor \
  font-manager \
  file \
  file-roller

# ==============================================================================
# 3. Bibliotecas comunes de compilación y desarrollo
# Dependencias que suelen pedir paquetes nativos de Python, C/C++ y herramientas gráficas.
# ==============================================================================

sudo apt install -y \
  libcairo2-dev \
  libpango1.0-dev \
  libgirepository1.0-dev \
  libssl-dev \
  libffi-dev \
  libsqlite3-dev \
  libbz2-dev \
  liblzma-dev \
  zlib1g-dev \
  libreadline-dev \
  libncurses-dev \
  libncursesw5-dev \
  libxml2-dev \
  libxmlsec1-dev \
  libxslt1-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libwebp-dev \
  libopenblas-dev \
  liblapack-dev \
  gfortran \
  libhdf5-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  libx11-dev \
  libxext-dev \
  libxrender-dev \
  libxtst-dev \
  libxi-dev \
  libcanberra-gtk-module \
  libcanberra-gtk3-module

# ==============================================================================
# 4. Python moderno para desarrollo
# Solo base de Python del sistema; el stack científico pesado mejor aislarlo aparte.
# ==============================================================================

sudo apt install -y \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  python3-setuptools \
  python3-wheel

# sudo apt install -y python3-tk
# sudo apt install -y python3-numpy
# sudo apt install -y python3-scipy
# sudo apt install -y python3-matplotlib
# sudo apt install -y python3-pandas
# sudo apt install -y python3-sklearn
# sudo apt install -y python3-opencv
# sudo apt install -y python3-pil
# sudo apt install -y python3-pyqt5
# sudo apt install -y ipython3
# sudo apt install -y jupyter-notebook

# Nota:
# Para trabajo real conviene usar entornos virtuales o Conda/Mamba,
# no meter todo el stack científico al Python del sistema. Ejemplo:
#
# python3 -m venv ~/venvs/ml
# source ~/venvs/ml/bin/activate
# pip install --upgrade pip wheel setuptools
# pip install numpy scipy pandas matplotlib scikit-learn jupyterlab torch torchvision

# ==============================================================================
# 5. Programación, editores e IDEs
# Editores, linters, depuradores y utilerías para código y revisión.
# ==============================================================================

sudo apt install -y \
  code \
  gedit \
  gedit-plugins \
  vim \
  neovim \
  emacs \
  meld \
  uncrustify \
  universal-ctags \
  sqlitebrowser \
  sqlcipher \
  shellcheck \
  shfmt \
  clang \
  clang-format \
  clang-tidy \
  lldb \
  gdb \
  valgrind \
  cppcheck

# ------------------------------------------------------------------------------
# Docker CE - instalación de motor, CLI y plugins
# Se agrega también el usuario actual al grupo docker.
# ------------------------------------------------------------------------------

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo usermod -aG docker "$USER"

# ==============================================================================
# 6. Java, R, Octave y herramientas científicas
# Lo comentado queda como reserva para activarlo según la máquina o el curso.
# ==============================================================================

# sudo apt install -y openjdk-21-jdk
# sudo apt install -y r-base
# sudo apt install -y r-base-dev
# sudo apt install -y octave
# sudo apt install -y octave-control
# sudo apt install -y octave-image
# sudo apt install -y octave-io
# sudo apt install -y octave-optim
# sudo apt install -y octave-signal
# sudo apt install -y octave-statistics
# sudo apt install -y octave-symbolic

sudo apt install -y \
  geogebra

# ==============================================================================
# 7. LaTeX y escritura académica
# Cobertura amplia para documentos, bibliografía y compilación con LuaLaTeX/XeLaTeX.
# ==============================================================================

sudo apt install -y \
  texlive \
  texlive-base \
  texlive-latex-base \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-science \
  texlive-lang-spanish \
  texlive-humanities \
  texlive-bibtex-extra \
  texlive-publishers \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-luatex \
  texlive-xetex \
  biber \
  latexmk \
  texmaker \
  chktex

# `texlive-full` queda fuera porque dispara mucho el tamaño de instalación.
# sudo apt install -y texlive-full

# ==============================================================================
# 8. Diseño gráfico, imagen y creación visual
# Herramientas generales para diagramas, mapa de bits, vectorial y anotación.
# ==============================================================================

# Krita puede activarse si la máquina se usará más para ilustración o tableta.
# sudo apt install -y krita

sudo apt install -y \
  gimp \
  inkscape \
  scribus \
  blender \
  imagemagick \
  graphviz \
  dia \
  xournalpp

# ==============================================================================
# 9. Multimedia: audio, video, captura, edición
# Cubre reproducción, grabación, streaming, edición y descarga de medios.
# ==============================================================================

sudo apt install -y \
  ffmpeg \
  vlc \
  audacity \
  obs-studio \
  obs-plugins \
  kdenlive \
  handbrake \
  yt-dlp \
  v4l2loopback-dkms \
  cheese

# ==============================================================================
# 10. Codecs, GStreamer y multimedia restringida
# Sirve para evitar faltantes comunes de reproducción y aceleración multimedia.
# ==============================================================================

sudo apt install -y \
  ubuntu-restricted-extras \
  libavcodec-extra \
  gstreamer1.0-libav \
  gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-ugly \
  gstreamer1.0-vaapi \
  vainfo

# ==============================================================================
# 11. Sonido moderno Ubuntu 24.04: PipeWire, WirePlumber, ALSA
# Deja lista la pila de audio actual de Ubuntu, incluido Bluetooth.
# ==============================================================================

sudo apt install -y \
  pipewire \
  pipewire-audio \
  pipewire-pulse \
  pipewire-alsa \
  wireplumber \
  pulseaudio-utils \
  alsa-utils \
  pavucontrol \
  libspa-0.2-bluetooth \
  bluez \
  blueman


# ==============================================================================
# 12. Productividad, documentos y PDF
# Oficina, diccionarios en español, utilerías PDF y locale para trabajo diario.
# ==============================================================================

sudo apt install -y \
  libreoffice \
  libreoffice-l10n-es \
  libreoffice-help-es \
  language-pack-es \
  language-pack-gnome-es \
  hunspell-es \
  hyphen-es \
  mythes-es \
  okular \
  okular-extra-backends \
  evince \
  pdfarranger \
  qpdf \
  poppler-utils \
  calibre \
  zim \
  planner \
  taskwarrior \
  rclone

# Locale en español de México para formatos de fecha, números y medidas.
sudo locale-gen es_MX.UTF-8

sudo update-locale \
  LANG=es_MX.UTF-8 \
  LC_TIME=es_MX.UTF-8 \
  LC_NUMERIC=es_MX.UTF-8 \
  LC_MONETARY=es_MX.UTF-8 \
  LC_PAPER=es_MX.UTF-8 \
  LC_MEASUREMENT=es_MX.UTF-8

# ==============================================================================
# 13. Administración del sistema
# Utilerías gráficas para discos, respaldos, firewall y limpieza básica.
# ==============================================================================

sudo apt install -y \
  gparted \
  synaptic \
  gnome-disk-utility \
  gnome-system-monitor \
  baobab \
  timeshift \
  deja-dup \
  gufw \
  bleachbit

# ==============================================================================
# 14. Internet, red y transferencia
# Acceso remoto, diagnóstico de red y transferencia de archivos.
# ==============================================================================

sudo apt install -y \
  filezilla \
  uget \
  transmission-gtk \
  remmina \
  remmina-plugin-rdp \
  remmina-plugin-vnc \
  openssh-client \
  openssh-server \
  net-tools \
  nmap \
  traceroute \
  whois \
  dnsutils \
  #iperf3 \
  #wireshark

# Si activas Wireshark y quieres capturar sin usar root:
#
# sudo usermod -aG wireshark "$USER"

# ==============================================================================
# 15. GNOME y personalización
# Ajustes finos del escritorio y manejo simple de extensiones.
# ==============================================================================

sudo apt install -y \
  gnome-tweaks \
  gnome-shell-extension-manager \
  chrome-gnome-shell \
  gnome-browser-connector

# ==============================================================================
# 16. Tipografías
# Fuentes útiles para código, documentos y compatibilidad con archivos de Office.
# ==============================================================================

sudo apt install -y \
  fonts-crosextra-carlito \
  fonts-crosextra-caladea \
  fonts-firacode \
  fonts-jetbrains-mono \
  fonts-noto \
  fonts-noto-core \
  fonts-noto-extra \
  fonts-noto-color-emoji \
  fonts-noto-cjk \
  fonts-liberation \
  ttf-mscorefonts-installer

# ==============================================================================
# 17. Limpieza
# Retira dependencias sobrantes y limpia caché al final.
# ==============================================================================

sudo apt autoremove -y
sudo apt autoclean

echo
echo "================================================================"
echo "Instalación APT principal completada para Ubuntu 24.04 LTS"
echo "Reinicia el sistema si se actualizaron kernel, drivers, grupos o servicios."
echo "================================================================"
