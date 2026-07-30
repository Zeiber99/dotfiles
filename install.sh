#!/usr/bin/env bash

# Salir si ocurre un error
set -e

echo "=========================================="
echo "   Iniciando instalación de Dotfiles...   "
echo "=========================================="

# 1. Paquetes oficiales de Pacman
PACKAGES_PACMAN=(
    base-devel
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

# 2. Paquetes de AUR (añade aquí las apps que requieran yay)
PACKAGES_AUR=(
    # Ejemplo: hyprpicker
)

echo "--> Instalando paquetes oficiales del sistema..."
sudo pacman -Syu --needed --noconfirm "${PACKAGES_PACMAN[@]}"

# 3. Instalación de yay (si no está instalado)
if ! command -v yay &> /dev/null; then
    echo "--> yay no está instalado. Compilando e instalando yay..."
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    cd "$TEMP_DIR/yay"
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    echo "--> yay instalado correctamente."
else
    echo "--> yay ya está instalado."
fi

# 4. Instalación de paquetes de AUR (si la lista no está vacía)
if [ ${#PACKAGES_AUR[@]} -gt 0 ]; then
    echo "--> Instalando paquetes de AUR con yay..."
    yay -S --needed --noconfirm "${PACKAGES_AUR[@]}"
fi

# 5. Clonar o verificar el repositorio de dotfiles
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "--> Clonando repositorio desde GitHub..."
    git clone https://github.com/Zeiber99/dotfiles.git "$DOTFILES_DIR"
fi

# 6. Crear enlaces simbólicos
echo "--> Vinculando configuraciones..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
ln -sf "$DOTFILES_DIR/config/fastfetch" "$HOME/.config/fastfetch"
ln -sf "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"

echo "=========================================="
echo "   ¡Instalación completada con éxito!     "
echo "=========================================="
