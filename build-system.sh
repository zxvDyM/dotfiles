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
    clang gcc gdb nasm fasm \
    unzip \
    kitty \
    polkit \
    elogind \
    git \
    htop tree curl wget \
    pipewire alsa-pipewire wireplumber \
    firefox

# Habilitar LightDM
echo "🖥️ Habilitando LightDM..."
sudo ln -sf /etc/sv/lightdm /var/service

# Detectar base path dentro del repo
DOTFILES_BASE_PATH=~/.dotfiles
if [ -d "$DOTFILES_BASE_PATH/dotfiles" ]; then
    DOTFILES_BASE_PATH="$DOTFILES_BASE_PATH/dotfiles"
    echo "📂 Usando subcarpeta 'dotfiles' como base: $DOTFILES_BASE_PATH"
else
    echo "📂 Usando la raíz del repositorio como base: $DOTFILES_BASE_PATH"
fi

# Enlace para Emacs
if [ -f "$DOTFILES_BASE_PATH/Emacs/emacs" ]; then
    ln -sf "$DOTFILES_BASE_PATH/Emacs/emacs" ~/.emacs
    echo "📎 Enlace creado para ~/.emacs"
else
    echo "⚠️  Archivo de Emacs no encontrado: $DOTFILES_BASE_PATH/Emacs/emacs"
fi

# .gdbinit
echo "⚙️  Configurando GDB..."
cat > ~/.gdbinit <<EOF
set breakpoint pending on
set disassembly-flavor intel
EOF

# Añadir usuario a grupos
echo "👤 Añadiendo usuario a grupos video, audio, input, network..."
sudo usermod -aG video,audio,input,network "$(whoami)"

# Activar servicios PipeWire (sin systemd)
echo "🎵 Configurando inicio automático de PipeWire (sin systemd)..."
mkdir -p ~/.config/autostart

cat > ~/.config/autostart/pipewire.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=pipewire
Name=PipeWire
EOF

cat > ~/.config/autostart/wireplumber.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=wireplumber
Name=WirePlumber
EOF

# Reiniciar servicios habilitados
echo "🔁 Reiniciando servicios habilitados..."
sudo sv restart dbus
sudo sv restart elogind
sudo sv restart NetworkManager
sudo sv restart lightdm

# Mostrar estado de servicios
echo "📋 Servicios activos:"
sudo sv status sshd dbus elogind NetworkManager lightdm

echo "✅ Configuración completada con éxito."
echo "🔁 Reinicia tu sistema para aplicar todos los cambios."
