#!/bin/bash
set -eu

echo "🛠️  Iniciando la configuración del sistema Void Linux..."

# Verificar acceso a dotfiles
if [ ! -d ~/dotfiles ]; then
    echo "❌ Directorio ~/dotfiles no encontrado. Aborta la configuración."
    exit 1
fi

# Advertencia sobre uso de sudo
echo "⚠️  Este script requiere privilegios de sudo. Asegúrate de tener acceso."

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
    neofetch \
    fontconfig \
    pandoc fd

# Instalar Rust pogramming languege
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install cargo-makedocs

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

# Instalar Iosevka Nerd Font si no está
echo "🔤 Verificando si Iosevka Nerd Font ya está instalada..."
if fc-list | grep -iq "Iosevka Nerd Font"; then
    echo "✅ Iosevka Nerd Font ya está instalada. Saltando instalación..."
else
    echo "📥 Instalando Iosevka Nerd Font..."

    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip"
    FONT_DEST="$HOME/.local/share/fonts"

    mkdir -p "$FONT_DEST"

    pushd /tmp > /dev/null
    curl -LO "$FONT_URL"

    unzip -q Iosevka.zip -d Iosevka
    cp -v Iosevka/*.ttf "$FONT_DEST/"

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

# Instalar plugins útiles
ZSH_PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
    echo "🔌 Instalando zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    echo "🔌 Instalando zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
fi

# Nota sobre Zsh
echo "ℹ️ Si no ves los cambios de Zsh, ejecuta: source ~/.zshrc o reinicia la terminal."

# Nota sobre dotfiles
echo "⚠️ NOTA: Tus dotfiles NO se eliminaron. Puedes hacerlo manualmente si lo deseas:"
echo "    rm -rf ~/dotfiles"

# Reinicio opcional
read -p "🔁 ¿Deseas reiniciar ahora para aplicar los cambios? [s/N] " RESP
if [[ "$RESP" =~ ^[Ss]$ ]]; then
    echo "🔄 Reiniciando..."
    sudo reboot
else
    echo "🛑 Reinicio cancelado. Puedes reiniciar manualmente más tarde."
fi

echo "✅ Configuración completada con éxito."
