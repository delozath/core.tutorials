#!/usr/bin/env bash

set -e

# ==============================================================================
# Flatpak para Ubuntu 24.04
# Apps de escritorio instaladas desde Flathub.
# ==============================================================================

sudo apt update
sudo apt install -y flatpak gnome-software-plugin-flatpak

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub com.spotify.Client
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub com.slack.Slack
flatpak install -y flathub us.zoom.Zoom
flatpak install -y flathub org.shotcut.Shotcut
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub org.onlyoffice.desktopeditors
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub com.github.johnfactotum.Foliate

echo
echo "================================================================"
echo "Instalación Flatpak completada para Ubuntu 24.04 LTS"
echo "Cierra sesión o reinicia si quieres integrar todos los accesos al escritorio."
echo "================================================================"
