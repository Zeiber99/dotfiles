#!/usr/bin/env bash

set -e

echo "=========================================="
echo "   Iniciando instalación de Dotfiles...   "
echo "=========================================="

# 1. Lista súper completa de paquetes (Pacman)
PACKAGES_PACMAN=(
    # Compilación y Control de Versiones
    base-devel
    git
    curl
    
    # Controladores Gráficos y Aceleración para VMware
    mesa
    open-vm-tools
    xf86-video-vmware
    xorg-xwayland
    
    # Gestor de Inicio de Sesión (SDDM + Dependencias Qt)
    sddm
    qt5-quickcontrols2
    qt5-graphicaleffects
    
    # Entorno Hyprland y Wayland
    hyprland
    hyprpaper
    hyprlock
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit-kde-agent
    qt5-wayland
    qt6-wayland
    
    # Fuentes, Terminal y Utilidades
    fastfetch
    foot
    librsvg
    less
    ttf-font-awesome
)

echo "--> Instalando paquetes oficiales con Pacman..."
sudo pacman -Syu --needed --noconfirm "${PACKAGES_PACMAN[@]}"

# 2. Habilitar servicios clave de Systemd
echo "--> Habilitando servicios de arranque (SDDM y VMware Tools)..."
sudo systemctl enable sddm.service
sudo systemctl enable vmtoolsd.service

# 3. Instalación de yay (Helper para AUR)
if ! command -v yay &> /dev/null; then
    echo "--> Compilando e instalando yay..."
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    cd "$TEMP_DIR/yay"
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf "$TEMP_DIR"
fi

# 4. Verificar o clonar repositorio
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "--> Clonando repositorio desde GitHub..."
    git clone https://github.com/Zeiber99/dotfiles.git "$DOTFILES_DIR"
fi

# 5. Crear enlaces simbólicos
echo "--> Vinculando archivos de configuración..."
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
ln -sf "$DOTFILES_DIR/config/fastfetch" "$HOME/.config/fastfetch"
ln -sf "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"

echo "=========================================="
echo "   ¡Instalación completada con éxito!     "
echo "   Reinicia el sistema para entrar a la GUI"
echo "=========================================="
