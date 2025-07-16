#!/bin/bash
set -e  # Detener el script si algún comando falla

echo "🛠️  Iniciando la configuración del sistema Void Linux..."

# Actualizar el sistema
echo "📦 Actualizando el sistema..."
sudo xbps-install -Syu

# Habilitar servicios esenciales
echo "🔌 Habilitando servicios esenciales..."
sudo ln -sf /etc/sv/sshd /var/service
sudo ln -sf /etc/sv/dbus /var/service
sudo ln -sf /etc/sv/elogind /var/service
sudo ln -sf /etc/sv/NetworkManager /var/service

# Instalar paquetes necesarios
echo "📦 Instalando paquetes del sistema..."
sudo xbps-install -Sy \
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
    elogind \
    git \
    htop tree curl wget \
    pipewire alsa-pipewire wireplumber \
    -y

# Habilitar LightDM
echo "🖥️ Habilitando LightDM..."
sudo ln -sf /etc/sv/lightdm /var/service

# --- Configuración de Dotfiles ---
echo "📁 Clonando dotfiles desde GitHub..."
if [ -d ~/.dotfiles ]; then
    echo "✔️  El directorio ~/.dotfiles ya existe. Saltando clonación."
else
    git clone https://github.com/zxvDyM/dotfiles.git ~/.dotfiles
    echo "📁 Dotfiles clonados en ~/.dotfiles"
fi

# Detectar base path dentro del repo
DOTFILES_BASE_PATH=~/.dotfiles
if [ -d "$DOTFILES_BASE_PATH/dotfiles" ]; then
    DOTFILES_BASE_PATH="$DOTFILES_BASE_PATH/dotfiles"
    echo "📂 Usando subcarpeta 'dotfiles' como base: $DOTFILES_BASE_PATH"
else
    echo "📂 Usando la raíz del repositorio como base: $DOTFILES_BASE_PATH"
fi

# Crear carpetas necesarias
mkdir -p ~/.config/i3
mkdir -p ~/.config/kitty
mkdir -p ~/.local/share/fonts

# Enlace para Emacs
ln -sf "$DOTFILES_BASE_PATH/Emacs/emacs" ~/.emacs

# Configuración i3
I3_CONFIG_REPO_PATH="$DOTFILES_BASE_PATH/Config/i3/config.txt"
I3_CONFIG_LOCAL_PATH="$HOME/.config/i3/config"

if [ -f "$I3_CONFIG_REPO_PATH" ]; then
    cp "$I3_CONFIG_REPO_PATH" "$I3_CONFIG_LOCAL_PATH"
    echo "✔️  Configuración de i3 copiada desde $I3_CONFIG_REPO_PATH"
else
    echo "⚠️  No se encontró $I3_CONFIG_REPO_PATH. Asegúrate de crear ese archivo."
fi

# Configuración de kitty
if [ -f "$DOTFILES_BASE_PATH/kitty/kitty.conf" ]; then
    ln -sf "$DOTFILES_BASE_PATH/kitty/kitty.conf" ~/.config/kitty/kitty.conf
    echo "✔️  Configuración de kitty enlazada."
else
    echo "⚠️  No se encontró kitty.conf, creando configuración por defecto con Iosevka Nerd Font..."
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
    echo "⚠️  No se encontró .bashrc en el repositorio."
fi

# Fuente Iosevka
echo "🔤 Instalando fuente Iosevka..."
if [ -d "$DOTFILES_BASE_PATH/Font/Iosevka" ]; then
    cp "$DOTFILES_BASE_PATH/Font/Iosevka/"*.ttf ~/.local/share/fonts/
    fc-cache -fv
else
    echo "❌ No se encontró la carpeta de fuentes Iosevka en $DOTFILES_BASE_PATH/Font/Iosevka"
    exit 1
fi

# gf2 si existe
if [ -f "$DOTFILES_BASE_PATH/gf/gf/gf2" ]; then
    cp "$DOTFILES_BASE_PATH/gf/gf/gf2" ~/.gf2
    chmod +x ~/.gf2
else
    echo "⚠️  No se encontró gf2."
fi

# .gdbinit
echo "⚙️  Configurando GDB..."
echo -e "set breakpoint pending on\nset disassembly-flavor intel" > ~/.gdbinit

# Añadir usuario a grupos
echo "👤 Añadiendo usuario a grupos video, audio, input, network..."
sudo usermod -aG video,audio,input,network "$(whoami)"

# Activar servicios PipeWire
echo "🎵 Activando servicios PipeWire (usuario)..."
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber

echo "✅ Configuración completada con éxito."
echo "🔁 Reinicia tu sistema para aplicar todos los cambios."
