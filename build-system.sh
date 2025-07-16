#!/bin/bash
set -e  # Detener el script si algún comando falla

echo "🛠️  Iniciando la configuración del sistema Void Linux..."

# Actualizar el sistema
echo "📦 Actualizando el sistema..."
sudo xbps-install -Syu

# Instalar paquetes necesarios
echo "📦 Instalando paquetes del sistema..."
sudo xbps-install -Sy \
    i3 i3status dmenu \
    emacs-gtk3 \
    clang gcc gdb nasm fasm \
    unzip \
    kitty zsh \
    polkit \
    htop curl wget

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
    if [ ! -L ~/.emacs ]; then
        ln -sf "$DOTFILES_BASE_PATH/Emacs/emacs" ~/.emacs
        echo "📎 Enlace creado para ~/.emacs"
    else
        echo "⚠️ El enlace simbólico ~/.emacs ya existe"
    fi
else
    echo "⚠️  Archivo de Emacs no encontrado: $DOTFILES_BASE_PATH/Emacs/emacs"
fi

# .gdbinit
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

# Establecer Zsh como shell predeterminada para el usuario actual
echo "🔁 Estableciendo Zsh como shell predeterminada..."
chsh -s /bin/zsh "$(whoami)"

# Agregar variables al archivo .zshrc
if [ ! -f "$HOME/.zshrc" ]; then
    echo "⚙️  Generando archivo .zshrc básico..."
    cat > "$HOME/.zshrc" <<EOF
# ~/.zshrc básico
export EDITOR=emacs
export VISUAL=emacs
export TERM=kitty
EOF
else
    echo "⚙️  .zshrc ya existe, añadiendo las variables necesarias..."
    # Añadir las variables al final del archivo si no existen
    grep -qxF 'export EDITOR=emacs' "$HOME/.zshrc" || echo 'export EDITOR=emacs' >> "$HOME/.zshrc"
    grep -qxF 'export VISUAL=emacs' "$HOME/.zshrc" || echo 'export VISUAL=emacs' >> "$HOME/.zshrc"
    grep -qxF 'export TERM=kitty' "$HOME/.zshrc" || echo 'export TERM=kitty' >> "$HOME/.zshrc"
fi

echo "✅ Configuración completada con éxito."
echo "🔁 Reinicia tu sistema para aplicar todos los cambios."
