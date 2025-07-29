#!/bin/bash
set -eu

echo "🛠️ Iniciando configuración del sistema Debian..."

# Verificar acceso a dotfiles
if [ ! -d ~/dotfiles ]; then
    echo "❌ Directorio ~/dotfiles no encontrado. Aborta la configuración."
    exit 1
fi

# Verificar privilegios de sudo
if ! sudo -v; then
    echo "❌ Necesitas acceso a sudo. Aborta la configuración."
    exit 1
fi

# Actualizar sistema
echo "📦 Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Copiar configuración de Emacs
echo "📝 Copiando configuración de Emacs..."
if [ -d ~/.emacs.d ]; then
    echo "📁 Backup de Emacs anterior..."
    mv ~/.emacs.d ~/.emacs.d.backup.$(date +%s)
fi
cp -r ~/dotfiles/.emacs.d/ ~/.emacs.d

# Instalar paquetes necesarios
echo "📦 Instalando paquetes esenciales..."
sudo apt install -y \
    emacs \
    clang gcc gdb nasm \
    unzip curl wget git \
    zsh kitty \
    okular \
    htop neofetch \
    fontconfig \
    pandoc fd-find \
    i3 i3status dmenu \
    pulseaudio playerctl \
    brightnessctl acpi \
    xbacklight

# Configurar Kitty
echo "🖥️ Configurando Kitty..."
mkdir -p ~/.config/kitty/
cp ~/dotfiles/kitty.conf ~/.config/kitty/kitty.conf

# Configurar GDB
echo "⚙️ Configurando GDB..."
cat > ~/.gdbinit <<EOF
set breakpoint pending on
set disassembly-flavor intel
EOF

# Instalar Iosevka Nerd Font si no está
echo "🔤 Verificando Iosevka Nerd Font..."
if fc-list | grep -iq "Iosevka Nerd Font"; then
    echo "✅ Iosevka Nerd Font ya está instalada."
else
    echo "📥 Instalando Iosevka Nerd Font..."
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.zip"
    FONT_DEST="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DEST"

    tmpdir=$(mktemp -d)
    pushd "$tmpdir" > /dev/null
    curl -LO "$FONT_URL"
    unzip -q Iosevka.zip -d Iosevka
    cp -v Iosevka/*.ttf "$FONT_DEST/"
    popd > /dev/null
    rm -rf "$tmpdir"

    echo "📦 Recargando caché de fuentes..."
    fc-cache -fv
    echo "✅ Iosevka Nerd Font instalada."
fi

# Instalar Oh My Zsh y Powerlevel10k
echo "💡 Instalando Oh My Zsh y Powerlevel10k..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no KEEP_ZSHRC=yes CHSH=no \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh ya instalado."
fi

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "✅ Powerlevel10k ya instalado."
fi

ZSH_PLUGIN_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
fi

# Instalar Rust (al final para evitar reinicio del entorno de shell)
echo "🦀 Instalando Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
cargo install cargo-makedocs

# Cambiar shell al final
echo "🔁 Estableciendo Zsh como shell predeterminada..."
ZSH_PATH=$(command -v zsh)
if grep -q "$ZSH_PATH" /etc/shells; then
    chsh -s "$ZSH_PATH"
    echo "✅ Shell cambiado a Zsh. Reinicia sesión para aplicar."
else
    echo "⚠️ Zsh no en /etc/shells. Agrega '$ZSH_PATH' manualmente si es necesario."
fi

# Nota sobre dotfiles
echo "⚠️ NOTA: Los dotfiles siguen en ~/dotfiles. Puedes eliminarlos manualmente si lo deseas."

# Reinicio opcional
read -p "🔁 ¿Deseas reiniciar ahora para aplicar los cambios? [s/N] " RESP
if [[ "$RESP" =~ ^[Ss]$ ]]; then
    echo "🔄 Reiniciando..."
    sudo reboot
else
    echo "🛑 Reinicio cancelado. Puedes reiniciar manualmente luego."
fi

echo "✅ Configuración finalizada correctamente en Debian."
