#!/bin/bash
set -eu  # Detener si hay error o variable no definida

echo "🛠️  Iniciando la configuración del sistema Void Linux..."

# Actualizar el sistema
echo "📦 Actualizando el sistema..."
sudo xbps-install -Syu

# Copiar configuración de Emacs (haciendo backup si ya existe)
echo "📝 Copiando configuración de Emacs..."
if [ -d ~/.emacs.d ]; then
    echo "📁 Se detectó una configuración previa de Emacs. Haciendo backup..."
    mv ~/.emacs.d ~/.emacs.d.backup.$(date +%s)
fi
cp -r ~/dotfiles/.emacs.d/ ~/.emacs.d

# Instalar paquetes del sistema
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

# Configurar terminal Kitty
echo "🖥️ Configurando Kitty..."
mkdir -p ~/.config/kitty/
cp ~/dotfiles/kitty.conf ~/.config/kitty/kitty.conf

# Configurar GDB
echo "⚙️  Configurando GDB..."
cat > ~/.gdbinit <<EOF
set breakpoint pending on
set disassembly-flavor intel
EOF

# Verificar si Iosevka Nerd Font está instalada
echo "🔤 Verificando si Iosevka Nerd Font ya está instalada..."
if fc-list | grep -iq "Iosevka Nerd Font"; then
    echo "✅ Iosevka Nerd Font ya está instalada. Saltando instalación..."
else
    echo "📥 Iosevka Nerd Font no encontrada. Procediendo con la instalación..."

    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip"
    FONT_DEST="$HOME/.local/share/fonts"

    mkdir -p "$FONT_DEST"

    pushd /tmp > /dev/null
    curl -LO "$FONT_URL"

    unzip -q Iosevka.zip -d Iosevka
    cp -v Iosevka/*.ttf "$FONT_DEST/"

    # Limpiar archivos temporales
    rm -rf Iosevka.zip Iosevka
    popd > /dev/null

    echo "📦 Recargando caché de fuentes..."
    fc-cache -fv

    echo "✅ Iosevka Nerd Font instalada correctamente."
fi

# Establecer Zsh como shell predeterminada
echo "🔁 Estableciendo Zsh como shell predeterminada..."
ZSH_PATH=$(command -v zsh)
if grep -q "$ZSH_PATH" /etc/shells; then
    chsh -s "$ZSH_PATH"
    echo "✅ Shell cambiado a Zsh."
else
    echo "⚠️  Zsh no está listado en /etc/shells. Agrega '$ZSH_PATH' manualmente si es necesario."
fi

# Instalar Oh My Zsh si no está instalado
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "✨ Instalando Oh My Zsh..."
    # ⚠️ Código remoto: asegúrate de revisarlo antes de ejecutar en sistemas de producción
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || \
    sh -c "$(wget -O- https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh ya está instalado. Saltando instalación."
fi

# Instalar tema Powerlevel10k si no está presente
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "🎨 Instalando tema Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "✅ Powerlevel10k ya está instalado. Saltando clonación."
fi

# Configuracion de .zshrc

# Nota sobre Zsh
echo "ℹ️ Si no ves los cambios de Zsh, ejecuta: source ~/.zshrc o reinicia la terminal."

# ⚠️ No eliminar dotfiles automáticamente, solo advertir
echo "⚠️ NOTA: Tus dotfiles NO se eliminaron. Puedes hacerlo manualmente si lo deseas:"
echo "    rm -rf ~/dotfiles"

echo "✅ Configuración completada con éxito."
echo "🔁 Reinicia tu sistema para aplicar todos los cambios."
