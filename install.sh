#!/usr/bin/env bash

set -e

echo "=========================================="
echo "   Iniciando instalación de Dotfiles...   "
echo "=========================================="

# 1. Paquetes del sistema con Pacman
PACKAGES_PACMAN=(
    base-devel
    git
    curl
    starship
    # Drivers VMware
    mesa
    open-vm-tools
    xf86-video-vmware
    xorg-xwayland
    # Gestor de sesión gráfico
    sddm
    qt5-quickcontrols2
    qt5-graphicaleffects
    # Entorno Hyprland
    hyprland
    hyprpaper
    hyprlock
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit-kde-agent
    qt5-wayland
    qt6-wayland
    # Terminal y utilidades
    fastfetch
    foot
    librsvg
    less
    ttf-font-awesome
)

echo "--> Instalando paquetes de Pacman..."
sudo pacman -Syu --needed --noconfirm "${PACKAGES_PACMAN[@]}"

# 2. Habilitar servicios del sistema
echo "--> Habilitando servicios (SDDM y VMware)..."
sudo systemctl enable sddm.service || true
sudo systemctl enable vmtoolsd.service || true

# 3. Instalación de yay (Helper de AUR)
if ! command -v yay &> /dev/null; then
    echo "--> Compilando e instalando yay..."
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    cd "$TEMP_DIR/yay"
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf "$TEMP_DIR"
fi

# 4. Clonar repositorio si no existe
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "--> Clonando repositorio desde GitHub..."
    git clone https://github.com/Zeiber99/dotfiles.git "$DOTFILES_DIR"
fi

# 5. Crear enlaces simbólicos
echo "--> Vinculando configuraciones..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
ln -sf "$DOTFILES_DIR/config/fastfetch" "$HOME/.config/fastfetch"
ln -sf "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"

echo "=========================================="
echo "   ¡Instalación completada con éxito!     "
echo "=========================================="
