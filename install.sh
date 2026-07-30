#!/usr/bin/env bash

set -e

echo "=========================================="
echo "    Iniciando instalación de Dotfiles...  "
echo "=========================================="

REPO_URL="https://github.com/Zeiber99/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# 1. Herramientas base
echo -e "\n[1/5] Verificando e instalando herramientas base..."
sudo pacman -Syu --needed --noconfirm git base-devel curl

# 2. Clonar o actualizar repositorio
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "\n[2/5] Clonando el repositorio de dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo -e "\n[2/5] El repositorio ya existe en $DOTFILES_DIR. Actualizando..."
    git -C "$DOTFILES_DIR" pull
fi

# 3. Instalador de AUR (yay)
if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    echo -e "\n[3/5] Instalando yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

AUR_HELPER=$(command -v paru || command -v yay)

# 4. Paquetes del entorno Hyprland (sin paquetes obsoletos)
PACKAGES=(
    hyprland hyprpaper hyprlock waybar rofi-wayland dunst foot starship
    thunar pavucontrol nwg-look xsettingsd wlogout wofi
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-kde-agent
    qt5-wayland qt6-wayland fastfetch
)

echo -e "\n[4/5] Instalando paquetes del entorno..."
$AUR_HELPER -S --needed --noconfirm "${PACKAGES[@]}"

# 5. Enlaces simbólicos hacia ~/.config
echo -e "\n[5/5] Creando enlaces simbólicos hacia ~/.config..."
mkdir -p "$HOME/.config"

for config_path in "$DOTFILES_DIR/config"/*; do
    folder_name=$(basename "$config_path")
    target="$HOME/.config/$folder_name"

    if [ -d "$target" ] && [ ! -L "$target" ]; then
        echo "Haciendo backup de $target a $target.bak"
        mv "$target" "$target.bak"
    fi

    ln -snf "$config_path" "$target"
    echo "Enlazado: $folder_name -> ~/.config/$folder_name"
done

echo -e "\n=========================================="
echo " ¡Instalación completada con éxito!"
echo "=========================================="
