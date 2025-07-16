#!/bin/bash
set -e # Detener el script si algún comando falla

echo "Iniciando la configuración del sistema Void Linux..."

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo xbps-install -Syu

# Habilitar servicios esenciales
echo "Habilitando servicios esenciales..."
sudo ln -s /etc/sv/sshd /var/service
sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/elogind /var/service
sudo ln -s /etc/sv/NetworkManager /var/service

# Instalar paquetes necesarios
echo "Instalando paquetes de sistema y desarrollo..."
sudo xbps-install -S \
    xorg \
    lightdm \
    lightdm-gtk-greeter \
    NetworkManager \
    i3 i3status i3lock dmenu \
    emacs-gtk3 \
    clang gcc gdb nasm fasm base-devel \
    unzip \
    kitty \
    polkit \
    elogind-extra \
    git \
    htop tree curl wget \
    -y

# Habilitar LightDM
echo "Habilitando LightDM..."
sudo ln -s /etc/sv/lightdm /var/service

# --- Configuración de Dotfiles ---
echo "Clonando configuraciones de dotfiles desde GitHub..."
if [ -d ~/.dotfiles ]; then
    echo "El directorio ~/.dotfiles ya existe. Saltando la clonación."
else
    git clone https://github.com/zxvDyM/dotfiles.git ~/.dotfiles
    echo "Repositorio dotfiles clonado en ~/.dotfiles"
fi

# Detectar base path dentro del repo
DOTFILES_BASE_PATH=~/.dotfiles
if [ -d "$DOTFILES_BASE_PATH/dotfiles" ]; then
    DOTFILES_BASE_PATH="$DOTFILES_BASE_PATH/dotfiles"
    echo "Usando subcarpeta 'dotfiles' como base: $DOTFILES_BASE_PATH"
else
    echo "Usando la raíz del repositorio como base: $DOTFILES_BASE_PATH"
fi

# Crear carpetas necesarias
mkdir -p ~/.config/i3
mkdir -p ~/.config/kitty

# Enlace para Emacs
ln -sf "$DOTFILES_BASE_PATH/Emacs/emacs" ~/.emacs

# i3: copiar configuración desde Config/i3/config.txt (con Nerd Font 15)
I3_CONFIG_REPO_PATH="$DOTFILES_BASE_PATH/Config/i3/config.txt"
I3_CONFIG_LOCAL_PATH="$HOME/.config/i3/config"

if [ -f "$I3_CONFIG_REPO_PATH" ]; then
    cp "$I3_CONFIG_REPO_PATH" "$I3_CONFIG_LOCAL_PATH"
    echo "Configuración de i3 copiada desde $I3_CONFIG_REPO_PATH a $I3_CONFIG_LOCAL_PATH"
else
    echo "⚠️ No se encontró $I3_CONFIG_REPO_PATH. Añade la configuración de i3 ahí."
fi

# Config kitty
if [ -f "$DOTFILES_BASE_PATH/kitty/kitty.conf" ]; then
    ln -sf "$DOTFILES_BASE_PATH/kitty/kitty.conf" ~/.config/kitty/kitty.conf
    echo "Configuración de kitty enlazada."
else
    echo "No se encontró kitty.conf, creando configuración por defecto con Iosevka Nerd Font..."
    cat <<EOF > ~/.config/kitty/kitty.conf
font_family Iosevka Nerd Font
font_size 12.0
enable_audio_bell no
EOF
fi

# .bashrc
if [ -f "$DOTFILES_BASE_PATH/.bashrc" ]; then
    ln -sf "$DOTFILES_BASE_PATH/.bashrc" ~/.bashrc
else
    echo "Advertencia: No se encontró .bashrc en el repositorio."
fi

# Instalar fuente Iosevka
echo "Instalando fuente Iosevka..."
if [ -d "$DOTFILES_BASE_PATH/Font/Iosevka" ]; then
    mkdir -p ~/.local/share/fonts
    cp "$DOTFILES_BASE_PATH/Font/Iosevka/"*.ttf ~/.local/share/fonts/
    fc-cache -fv
else
    echo "Error: No se encontró la carpeta de fuentes Iosevka."
    exit 1
fi

# Copiar gf2 si existe
if [ -f "$DOTFILES_BASE_PATH/gf/gf/gf2" ]; then
    cp "$DOTFILES_BASE_PATH/gf/gf/gf2" ~/.gf2
    chmod +x ~/.gf2
else
    echo "Advertencia: No se encontró gf2."
fi

# Configurar .gdbinit
echo -e "set breakpoint pending on\nset disassembly-flavor intel" > ~/.gdbinit

# Añadir usuario a grupos esenciales
echo "Añadiendo usuario a grupos video,audio,input,network..."
sudo usermod -aG video,audio,input,network "$(whoami)"

# Limpiar script actual (opcional, cuidado)
# rm -f "$(realpath "$0")"

echo "Configuración completada. Por favor reinicia el sistema."
