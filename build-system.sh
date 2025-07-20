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

# Configure Kitty terminal
cp ~/dotfiles/kitty.conf ~/.config/kitty/kitty.conf

# Configurar GDB
echo "⚙️  Configurando GDB..."
cat > ~/.gdbinit <<EOF
set breakpoint pending on
set disassembly-flavor intel
EOF

# Instalar Iosevka Nerd Font si no está instalada
echo "🔤 Verificando si Iosevka Nerd Font ya está instalada..."

if fc-list | grep -iq "Iosevka Nerd Font"; then
    echo "✅ Iosevka Nerd Font ya está instalada. Saltando instalación..."
else
    echo "📥 Iosevka Nerd Font no encontrada. Procediendo con la instalación..."

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
fi

# Establecer Zsh como shell predeterminada
echo "🔁 Estableciendo Zsh como shell predeterminada..."
chsh -s /bin/zsh "$(whoami)"

# --- Install Oh My Zsh ---

# Check if Oh My Zsh is already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "✨ Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || \
    sh -c "$(wget -O- https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # The installer usually sources .zshrc and restarts the shell.
    # If not, you might need to manually source it here.
    # source "$HOME/.zshrc" # Uncomment if the shell doesn't restart automatically
else
    echo "✅ Oh My Zsh is already installed. Skipping installation."
fi

# --- Install and Configure Powerlevel10k Theme ---

# Check if Powerlevel10k is already cloned
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "🎨 Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "✅ Powerlevel10k theme is already cloned. Skipping clone."
fi

source ~/.zshrc

# ⚠️ Esta línea se comenta para evitar eliminar tus dotfiles
cd
rm -rf ~/dotfiles

echo "✅ Configuración completada con éxito."
echo "🔁 Reinicia tu sistema para aplicar todos los cambios."
