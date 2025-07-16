#!/bin/bash
set -e

echo "Iniciando la configuración del sistema Void Linux..."

# Verificar que xbps-install está disponible
command -v xbps-install >/dev/null 2>&1 || {
    echo "❌ Error: xbps-install no encontrado. ¿Estás en Void Linux?"
    exit 1
}

# Actualizar el sistema
echo "🔄 Actualizando el sistema..."
sudo xbps-install -Syu -y

# Habilitar servicios esenciales
echo "⚙️ Habilitando servicios esenciales..."
sudo ln -sf /etc/sv/sshd /var/service
sudo ln -sf /etc/sv/dbus /var/service
sudo ln -sf /etc/sv/elogind /var/service
sudo ln -sf /etc/sv/NetworkManager /var/service

# Instalar paquetes necesarios
echo "📦 Instalando paquetes esenciales..."
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
    elogind-extra \
    git \
    htop tree curl wget \
    -y

# Habilitar LightDM
echo "🔌 Habilitando LightDM..."
sudo ln -sf /etc/sv/lightdm /var/service

# --- Dotfiles ---
echo "🗂️ Configurando dotfiles..."
DOTFILES_BASE_PATH="$HOME/.dotfiles"

if [ -d "$DOTFILES_BASE_PATH" ]; then
    echo "✅ Directorio ~/.dotfiles ya existe."
else
    git clone https://github.com/zxvDyM/dotfiles.git "$DOTFILES_BASE_PATH"
    echo "✅ Dotfiles clonados en $DOTFILES_BASE_PATH"
fi

# Verificar si hay subcarpeta dotfiles dentro del repo
if [ -d "$DOTFILES_BASE_PATH/dotfiles" ]; then
    DOTFILES_BASE_PATH="$DOTFILES_BASE_PATH/dotfiles"
    echo "📁 Subcarpeta 'dotfiles' detectada. Nueva base: $DOTFILES_BASE_PATH"
fi

# Crear carpetas necesarias
mkdir -p "$HOME/.config/i3"
mkdir -p "$HOME/.config/kitty"

# Enlace para Emacs
ln -sf "$DOTFILES_BASE_PATH/Emacs/emacs" "$HOME/.emacs"

# Enlace para i3
if [ -f "$DOTFILES_BASE_PATH/i3/config" ]; then
    ln -sf "$DOTFILES_BASE_PATH/i3/config" "$HOME/.config/i3/config"
else
    echo "⚠️ i3 config no encontrada en $DOTFILES_BASE_PATH/i3/config"
fi

# Enlace o fallback de kitty.conf
if [ -f "$DOTFILES_BASE_PATH/kitty/kitty.conf" ]; then
    ln -sf "$DOTFILES_BASE_PATH/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    echo "✅ Configuración de kitty enlazada."
else
    echo "⚠️ No se encontró kitty.conf. Creando archivo por defecto..."
    mkdir -p "$HOME/.config/kitty"
    cat <<EOF > "$HOME/.config/kitty/kitty.conf"
# Configuración de Kitty generada por el script
font_family Iosevka Nerd Font
font_size 12.0
enable_audio_bell no
EOF
    echo "✅ Configuración por defecto de kitty creada."
fi

# .bashrc
if [ -f "$DOTFILES_BASE_PATH/.bashrc" ]; then
    ln -sf "$DOTFILES_BASE_PATH/.bashrc" "$HOME/.bashrc"
else
    echo "⚠️ .bashrc no encontrado en los dotfiles"
fi

# Instalar fuente Iosevka
echo "🔤 Instalando fuente Iosevka..."
if [ -d "$DOTFILES_BASE_PATH/Font/Iosevka" ]; then
    mkdir -p "$HOME/.local/share/fonts"
    cp "$DOTFILES_BASE_PATH/Font/Iosevka/"*.ttf "$HOME/.local/share/fonts/"
    fc-cache -fv
    echo "✅ Fuente Iosevka instalada."
else
    echo "❌ No se encontró $DOTFILES_BASE_PATH/Font/Iosevka"
    exit 1
fi

# Copiar gf2 si existe
echo "📁 Copiando gf2..."
if [ -f "$DOTFILES_BASE_PATH/gf/gf/gf2" ]; then
    cp "$DOTFILES_BASE_PATH/gf/gf/gf2" "$HOME/.gf2"
    chmod +x "$HOME/.gf2"
    echo "✅ gf2 copiado a ~/.gf2"
else
    echo "⚠️ gf2 no encontrado. Saltando."
fi

# Configurar GDB
echo "🛠️ Configurando .gdbinit..."
cat <<EOF > "$HOME/.gdbinit"
set breakpoint pending on
set disassembly-flavor intel
EOF

# Añadir a grupos esenciales
echo "👤 Añadiendo usuario a grupos esenciales..."
sudo usermod -aG video,audio,input,network "$(whoami)"

# Limpieza
echo "🧹 Eliminando el script actual..."
SCRIPT_PATH="$(realpath "$0")"
rm -f "$SCRIPT_PATH"

# Confirmar reinicio
read -p "🔁 ¿Deseas reiniciar ahora? (y/N): " respuesta
if [[ "$respuesta" =~ ^[Yy]$ ]]; then
    sudo reboot
else
    echo "✅ Instalación completa. Reinicia cuando estés listo."
fi
