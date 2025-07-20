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

# --- Zshrc Management ---

# Create or append to .zshrc with basic editor settings
if [ ! -f "$HOME/.zshrc" ]; then
    echo "⚙️ Generating basic .zshrc file..."
    cat > "$HOME/.zshrc" <<'EOF_ZSHRC_BASE'
# ~/.zshrc basic setup
export EDITOR=emacs
export VISUAL=emacs

EOF_ZSHRC_BASE
else
    echo "📄 Appending configuration to existing .zshrc..."
    cat >> "$HOME/.zshrc" <<'EOF_ZSHRC_APPEND'

# Configuration added by script
export EDITOR=emacs
export VISUAL=emacs

EOF_ZSHRC_APPEND
fi

# --- Zsh Autocompletion ---

# Add basic autocompletion if not already present
if ! grep -q "autoload -Uz compinit" "$HOME/.zshrc"; then
    echo "🚀 Adding Zsh autocompletion setup to .zshrc..."
    cat >> "$HOME/.zshrc" <<'EOF_AUTOCOMPLETION'

# Enable basic autocompletion
autoload -Uz compinit
compinit
EOF_AUTOCOMPLETION
fi

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

# Configure .zshrc to use Powerlevel10k if not already set
if ! grep -q "ZSH_THEME=\"powerlevel10k\"" "$HOME/.zshrc"; then
    echo "✍️ Setting Powerlevel10k as the Zsh theme in .zshrc..."
    # Use awk or sed to replace ZSH_THEME line without creating new sections
    # This specifically replaces an existing ZSH_THEME="..." line
    awk -i inplace '/^ZSH_THEME=/ { $0="ZSH_THEME=\"powerlevel10k\"" } { print }' "$HOME/.zshrc"
    
    # Fallback if ZSH_THEME line doesn't exist, append it
    if ! grep -q "^ZSH_THEME=\"powerlevel10k\"" "$HOME/.zshrc"; then
        echo "Adding ZSH_THEME=\"powerlevel10k\" to .zshrc..."
        echo "ZSH_THEME=\"powerlevel10k\"" >> "$HOME/.zshrc"
    fi
else
    echo "✅ Powerlevel10k is already set as the Zsh theme. Skipping theme configuration."
fi

source ~/.zshrc

# ⚠️ Esta línea se comenta para evitar eliminar tus dotfiles
cd
rm -rf ~/dotfiles

echo "✅ Configuración completada con éxito."
echo "🔁 Reinicia tu sistema para aplicar todos los cambios."
