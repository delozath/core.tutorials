#!/usr/bin/env bash

set -e

# ==============================================================================
# Snap para Ubuntu 24.04
# Apps instaladas desde el canal oficial de Snap.
# ==============================================================================

sudo snap install spotify
sudo snap install discord
sudo snap install slack
sudo snap install code --classic
sudo snap install pycharm-community --classic
sudo snap install intellij-idea-community --classic
sudo snap install geogebra
sudo snap install zoom-client
sudo snap install obsidian --classic
sudo snap install postman
sudo snap install android-studio --classic

echo
echo "================================================================"
echo "Instalación Snap completada para Ubuntu 24.04 LTS"
echo "Verifica permisos y conexiones de interfaces si alguna app lo solicita."
echo "================================================================"
