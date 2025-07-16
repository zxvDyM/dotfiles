#!/bin/bash
set -e  # Detener el script si algún comando falla

echo "🔧 Iniciando configuración de Zsh, Oh My Zsh y Powerlevel10k..."

# 1. Instalar Zsh si no está instalado
if ! command -v zsh &> /dev/null; then
    echo "📦 Instalando Zsh..."
    sudo xbps-install -Sy zsh -y
else
    echo "✅ Zsh ya está instalado."
fi

# 2. Instalar Oh My Zsh (solo si no está)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "💡 Instalando Oh My Zsh (modo desatendido)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh ya está instalado."
fi

# 3. Instalar Powerlevel10k
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
    echo "🎨 Clonando Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "✅ Powerlevel10k ya está clonado."
fi

# 4. Configurar ~/.zshrc
ZSHRC="$HOME/.zshrc"
echo "🛠️ Configurando .zshrc..."

# Crear básico si no existe
if [ ! -f "$ZSHRC" ]; then
    cat <<EOF > "$ZSHRC"
# .zshrc generado automáticamente
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
source \$ZSH/oh-my-zsh.sh
EOF
    echo "✅ .zshrc básico creado."
else
    # Asegurar que export ZSH esté presente
    if ! grep -q 'export ZSH=' "$ZSHRC"; then
        echo 'export ZSH="$HOME/.oh-my-zsh"' >> "$ZSHRC"
    fi

    # Reemplazar o añadir ZSH_THEME
    if grep -q '^ZSH_THEME=' "$ZSHRC"; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
    else
        sed -i '/^export ZSH=/a ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC"
    fi

    # Asegurar que source oh-my-zsh está presente
    if ! grep -q 'source \$ZSH/oh-my-zsh.sh' "$ZSHRC"; then
        echo 'source $ZSH/oh-my-zsh.sh' >> "$ZSHRC"
    fi

    echo "✅ .zshrc actualizado."
fi

# 5. Cambiar shell por defecto a zsh si aún no lo es
if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo "🔄 Cambiando shell por defecto a Zsh..."
    chsh -s "$(command -v zsh)"
    echo "✅ Shell por defecto cambiado a Zsh."
else
    echo "✅ Zsh ya es tu shell por defecto."
fi

echo ""
echo "🎉 Configuración completada."
echo "📝 Cierra esta terminal y abre una nueva para aplicar los cambios."
echo "💡 Al iniciar Zsh por primera vez, Powerlevel10k te guiará con su asistente de configuración."
