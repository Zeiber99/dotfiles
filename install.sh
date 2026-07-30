#!/usr/bin/env bash

set -e # Detener el script si ocurre algún error

echo "=========================================="
echo "    Instalador de Dotfiles - Hyprland    "
echo "=========================================="

REPO_URL="https://github.com/Zeiber99/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# 1. Asegurar que Git y herramientas básicas están instaladas
echo -e "\n[1/5] Verificando e instalando herramientas base..."
sudo pacman -Syu --needed --noconfirm git base-devel

# 2. Clonar el repositorio si no existe localmente
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "\n[2/5] Clonando el repositorio de dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo -e "\n[2/5] El repositorio ya existe en $DOTFILES_DIR. Actualizando..."
    git -C "$DOTFILES_DIR" pull
fi

# 3. Instalar helper de AUR (yay) si no existe
if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    echo -e "\n[3/5] Instalando yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

AUR_HELPER=$(command -v paru || command -v yay)

# 4. Lista de programas del entorno (Hyprland, Waybar, Terminales, etc.)
PACKAGES=(
    hyprland waybar rofi-wayland dunst foot starship
    thunar pavucontrol nwg-look xsettingsd wlogout wofi
    ttf-font-awesome qt5-wayland qt6-wayland
)

echo -e "\n[4/5] Instalando paquetes del entorno..."
$AUR_HELPER -S --needed --noconfirm "${PACKAGES[@]}"

# 5. Crear enlaces simbólicos en ~/.config
echo -e "\n[5/5] Creando enlaces simbólicos hacia ~/.config..."
mkdir -p "$HOME/.config"

# Recorrer carpetas dentro de config/ y enlazarlas
for config_path in "$DOTFILES_DIR/config"/*; do
    folder_name=$(basename "$config_path")
    target="$HOME/.config/$folder_name"

    # Si ya existe un directorio que no sea un enlace simbólico, hace un backup
    if [ -d "$target" ] && [ ! -L "$target" ]; then
        echo "Haciendo backup de $target existente a $target.bak"
        mv "$target" "$target.bak"
    fi

    # Crea enlace simbólico (-s) forzado (-f) para reemplazar si existe
    ln -snf "$config_path" "$target"
    echo "Enlazado: $folder_name -> ~/.config/$folder_name"
done

echo -e "\n=========================================="
echo " ¡Instalación completada! Reinicia la sesión."
echo "=========================================="
