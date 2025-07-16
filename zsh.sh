#!/bin/bash
set -e

echo "Iniciando configuración de Zsh, Oh My Zsh y Powerlevel10k..."

# Instalar zsh si no está
if ! command -v zsh &> /dev/null; then
    sudo xbps-install -S zsh -y
else
    echo "Zsh ya instalado."
fi

# Descargar instalador Oh My Zsh y pedir confirmación para ejecutarlo
echo "Descargando instalador Oh My Zsh..."
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/install-ohmyzsh.sh

echo "Mostrando primeras 30 líneas del instalador:"
head -n 30 /tmp/install-ohmyzsh.sh
echo "..."

read -p "¿Ejecutar instalador de Oh My Zsh? (s/N): " confirm
if [[ "$confirm" =~ ^[Ss]$ ]]; then
    sh /tmp/install-ohmyzsh.sh --unattended
    echo "Oh My Zsh instalado."
else
    echo "Instalación de Oh My Zsh cancelada."
fi
rm /tmp/install-ohmyzsh.sh

# Clonar Powerlevel10k si no existe
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
else
    echo "Powerlevel10k ya clonado."
fi

# Configurar .zshrc
ZSHRC_PATH=~/.zshrc

if [ ! -f "$ZSHRC_PATH" ]; then
    echo "# Archivo .zshrc generado por script" > "$ZSHRC_PATH"
    echo "export ZSH=\"\$HOME/.oh-my-zsh\"" >> "$ZSHRC_PATH"
    echo "source \$ZSH/oh-my-zsh.sh" >> "$ZSHRC_PATH"
    echo ".zshrc creado."
fi

# Configurar tema powerlevel10k
if grep -q "^ZSH_THEME=" "$ZSHRC_PATH"; then
    sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC_PATH"
else
    sed -i "/^export ZSH=/a ZSH_THEME=\"powerlevel10k/powerlevel10k\"" "$ZSHRC_PATH"
fi

# Asegurar que se sourcea oh-my-zsh.sh
if ! grep -q "source \$ZSH/oh-my-zsh.sh" "$ZSHRC_PATH"; then
    echo "source \$ZSH/oh-my-zsh.sh" >> "$ZSHRC_PATH"
fi

# Cambiar shell a zsh si no está ya
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(which zsh)"
    echo "Shell por defecto cambiado a Zsh."
else
    echo "Zsh ya es shell por defecto."
fi

echo "Configuración de Zsh y Powerlevel10k completada."
echo "Cierra la terminal y ábrela de nuevo para aplicar cambios."
echo "La primera vez que inicies Zsh, Powerlevel10k te guiará en su configuración."
