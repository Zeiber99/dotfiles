#!/usr/bin/env bash

# Salir inmediatamente si ocurre un error
set -e

echo "=========================================="
echo "   Iniciando instalación de Dotfiles...   "
echo "=========================================="

# 1. Actualizar el sistema e instalar programas esenciales
echo "--> Instalando paquetes necesarios..."
sudo pacman -Syu --needed --noconfirm git hyprland fastfetch foot librsvg less

# 2. Asegurar que el repositorio está clonado
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "--> Clonando repositorio desde GitHub..."
    git clone https://github.com/Zeiber99/dotfiles.git "$DOTFILES_DIR"
fi

# 3. Crear directorio .config si no existe
mkdir -p "$HOME/.config"

# 4. Crear enlaces simbólicos
echo "--> Vinculando configuraciones..."
ln -sf "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
ln -sf "$DOTFILES_DIR/config/fastfetch" "$HOME/.config/fastfetch"
ln -sf "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"

echo "=========================================="
echo "   ¡Instalación completada con éxito!     "
echo "=========================================="

