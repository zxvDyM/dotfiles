#!/bin/bash
set -eu  # Detener el script si algún comando falla o si se usa una variable no definida

echo "🛠️  Iniciando la configuración del sistema Void Linux..."

# Actualizar el sistema
echo "📦 Actualizando el sistema..."
sudo xbps-install -Syu

# Copiar configuraciones de Emacs
echo "📝 Copiando configuración de Emacs..."
mkdir -p ~/.emacs.d
cp -r ~/dotfiles/.emacs.d/ ~/

# Instalar paquetes necesarios
echo "📦 Instalando paquetes del sistema..."
sudo xbps-install -Sy \
    okular \
    emacs-gtk3 \
    clang gcc gdb nasm fasm \
    unzip \
    kitty zsh \
    git \
    htop curl wget \
    neofetch

# ⚠️ Esta línea se comenta para evitar eliminar tus dotfiles
cd
rm -rf ~/dotfiles

# Configurar GDB
echo "⚙️  Configurando GDB..."
cat > ~/.gdbinit <<EOF
set breakpoint pending on
set disassembly-flavor intel
EOF

# Instalar Iosevka Nerd Font
echo "🔤 Instalando Iosevka Nerd Font..."

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip"
FONT_DEST="$HOME/.local/share/fonts"

mkdir -p "$FONT_DEST"
cd /tmp
curl -LO "$FONT_URL"

unzip -q Iosevka.zip -d Iosevka
cp -v Iosevka/*.ttf "$FONT_DEST/"

# Limpiar archivos temporales
rm -rf /tmp/Iosevka.zip /tmp/Iosevka

# Recargar caché de fuentes
echo "📦 Recargando caché de fuentes..."
fc-cache -fv

echo "✅ Iosevka Nerd Font instalada correctamente."

# Establecer Zsh como shell predeterminada
echo "🔁 Estableciendo Zsh como shell predeterminada..."
chsh -s /bin/zsh "$(whoami)"

# Crear o actualizar .zshrc
if [ ! -f "$HOME/.zshrc" ]; then
    echo "⚙️  Generando archivo .zshrc básico..."
    cat > "$HOME/.zshrc" <<EOF
# ~/.zshrc básico
export EDITOR=emacs
export VISUAL=emacs

EOF
else
    echo "⚙️  .zshrc ya existe, añadiendo configuraciones si faltan..."
    grep -qxF 'export EDITOR=emacs' "$HOME/.zshrc" || echo 'export EDITOR=emacs' >> "$HOME/.zshrc"
    grep -qxF 'export VISUAL=emacs' "$HOME/.zshrc" || echo 'export VISUAL=emacs' >> "$HOME/.zshrc"
fi

echo "✅ Configuración completada con éxito."
echo "🔁 Reinicia tu sistema para aplicar todos los cambios."
