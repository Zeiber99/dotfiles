#!/usr/bin/env bash
# ==============================================================================
# Instalador Maestro de Dotfiles - Clonación 1:1 del sistema
# ==============================================================================
set -e

# Colores para los mensajes
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${BLUE}==========================================${RESET}"
echo -e "${GREEN}    Iniciando Clonación de Sistema...     ${RESET}"
echo -e "${BLUE}==========================================${RESET}"

REPO_URL="https://github.com/Zeiber99/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# ------------------------------------------------------
# 1. Preparación del Sistema Base
# ------------------------------------------------------
echo -e "\n${BLUE}[1/7] Actualizando sistema y preparando base...${RESET}"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm git base-devel curl wget

# ------------------------------------------------------
# 2. Obtener los Dotfiles
# ------------------------------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "\n${BLUE}[2/7] Descargando tu configuración maestra...${RESET}"
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo -e "\n${BLUE}[2/7] Actualizando dotfiles existentes...${RESET}"
    git -C "$DOTFILES_DIR" pull
fi

# ------------------------------------------------------
# 3. Gestor de AUR (yay)
# ------------------------------------------------------
if ! command -v yay &> /dev/null; then
    echo -e "\n${BLUE}[3/7] Instalando gestor AUR (yay)...${RESET}"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# ------------------------------------------------------
# 4. Lista Maestra de Paquetes (Tu Ecosistema)
# ------------------------------------------------------
echo -e "\n${BLUE}[4/7] Instalando el ecosistema completo...${RESET}"

# Dividimos los paquetes por categorías para mantener el orden
PKG_SISTEMA=(
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber # Audio
    networkmanager bluez bluez-utils                             # Red y Bluetooth
    sddm qt5-quickcontrols2 qt5-graphicaleffects                 # Login Manager
    polkit-kde-agent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk # Permisos y portales
)

PKG_HYPRLAND=(
    hyprland hyprpaper hyprlock hypridle waybar rofi-wayland dunst
    foot starship wlogout wofi fastfetch
    qt5-wayland qt6-wayland nwg-look xsettingsd
)

PKG_FUENTES=(
    ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts-emoji
)

PKG_APPS=(
    thunar thunar-archive-plugin file-roller gvfs              # Gestor de archivos
    pavucontrol                                                # Control de audio
    brave-bin                                                  # Navegador principal
    kodi                                                       # Media center
    docker docker-compose                                      # Contenedores / Servidor
    go                                                         # Entorno de desarrollo
)

# Unimos todas las listas e instalamos
PAQUETES_TOTALES=("${PKG_SISTEMA[@]}" "${PKG_HYPRLAND[@]}" "${PKG_FUENTES[@]}" "${PKG_APPS[@]}")
yay -S --needed --noconfirm "${PAQUETES_TOTALES[@]}"

# ------------------------------------------------------
# 5. Habilitar Servicios del Sistema (Daemon)
# ------------------------------------------------------
echo -e "\n${BLUE}[5/7] Habilitando servicios en segundo plano...${RESET}"
sudo systemctl enable sddm.service          # Pantalla de inicio de sesión
sudo systemctl enable NetworkManager.service # Internet
sudo systemctl enable bluetooth.service      # Bluetooth
sudo systemctl enable docker.service         # Contenedores

# ------------------------------------------------------
# 6. Despliegue de Dotfiles (Symlinks Mágicos)
# ------------------------------------------------------
echo -e "\n${BLUE}[6/7] Inyectando configuración en el sistema...${RESET}"
mkdir -p "$HOME/.config"

for config_path in "$DOTFILES_DIR/config"/*; do
    folder_name=$(basename "$config_path")
    target="$HOME/.config/$folder_name"

    # Backup seguro si ya existe
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "${RED}Backup creado para: $folder_name${RESET}"
        mv "$target" "$target.bak_$(date +%s)"
    fi

    ln -snf "$config_path" "$target"
    echo -e "${GREEN}✔ Enlazado: $folder_name${RESET}"
done

# (Opcional) Si tienes un .bashrc o .zshrc en la raíz de tu repo, lo enlazamos aquí
if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    ln -snf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    echo -e "${GREEN}✔ Enlazado: .bashrc${RESET}"
fi

# ------------------------------------------------------
# 7. Post-Instalación
# ------------------------------------------------------
echo -e "\n${BLUE}[7/7] Ajustes finales...${RESET}"
# Asegurar que tu usuario tiene permisos para Docker
sudo usermod -aG docker $USER

echo -e "\n${GREEN}====================================================${RESET}"
echo -e "${GREEN} ¡Sistema clonado con éxito!                        ${RESET}"
echo -e "${GREEN} Por favor, reinicia tu PC para aplicar los cambios.${RESET}"
echo -e "${GREEN}====================================================${RESET}"
