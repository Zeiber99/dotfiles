#!/usr/bin/env bash

# Salir si hay errores
set -e

echo "=========================================="
echo "   Iniciando instalación de Dotfiles...   "
echo "=========================================="

# 1. Lista de paquetes esenciales para Hyprland y tu entorno
PACKAGES=(
    git
    hyprland
    hyprpaper
    hyprlock
    xdg-desktop-portal-hyprland
    polkit-kde-agent
    qt5-wayland
    qt6-wayland
    fastfetch
    foot
    librsvg
    less
    ttf-font-awesome
)

echo "--> Instalando paquetes del sistema..."
sudo pacman -Syu --needed --noconfirm "${PACKAGES[@]}"

# 2. Clonar o verificar el repositorio
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "--> Clonando repositorio desde GitHub..."
    git clone https://github.com/Zeiber99/dotfiles.git "$DOTFILES_DIR"
fi

# 3. Crear enlaces simbólicos
echo "--> Vinculando configuraciones..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
ln -sf "$DOTFILES_DIR/config/fastfetch" "$HOME/.config/fastfetch"
ln -sf "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"

echo "=========================================="
echo "   ¡Instalación completada con éxito!     "
echo "=========================================="
