#!/bin/bash
set -e # Detener el script si algún comando falla

echo "Iniciando la configuración de Zsh, Oh My Zsh y Powerlevel10k..."

# Instalar Zsh si no está ya instalado
echo "Instalando Zsh..."
# Verificar si zsh ya está instalado para evitar errores si se ejecuta varias veces
if ! command -v zsh &> /dev/null; then
    sudo xbps-install -S zsh -y
else
    echo "Zsh ya está instalado. Saltando instalación."
fi

# Instalar Oh My Zsh
echo "Instalando Oh My Zsh..."
# Usar la instalación desatendida para evitar prompts interactivos
# Verificar si Oh My Zsh ya está instalado
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh ya está instalado. Saltando instalación."
fi

# Instalar Powerlevel10k
echo "Clonando Powerlevel10k..."
# Verificar si Powerlevel10k ya está clonado
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "Powerlevel10k ya está clonado. Saltando clonación."
fi

# Configurar .zshrc
ZSHRC_PATH=~/.zshrc

echo "Configurando .zshrc para usar Powerlevel10k..."

# Crear un .zshrc si no existe (esto es importante si el usuario no tiene dotfiles para .zshrc)
if [ ! -f "$ZSHRC_PATH" ]; then
    echo "# .zshrc generado por el script de configuración de Zsh y Powerlevel10k" > "$ZSHRC_PATH"
    echo "export ZSH=\"\$HOME/.oh-my-zsh\"" >> "$ZSHRC_PATH"
    echo "source \$ZSH/oh-my-zsh.sh" >> "$ZSHRC_PATH"
    echo "Se ha creado un archivo ~/.zshrc básico."
fi

# Asegurarse de que el tema P10k esté configurado
# Usamos sed para reemplazar la línea ZSH_THEME o añadirla si no existe
if grep -q "^ZSH_THEME=" "$ZSHRC_PATH"; then
    sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC_PATH"
    echo "Se ha configurado Powerlevel10k como tema en tu .zshrc."
else
    # Si no hay ZSH_THEME, lo añadimos después de la línea ZSH
    sed -i "/^export ZSH=/a ZSH_THEME=\"powerlevel10k\/powerlevel10k\"" "$ZSHRC_PATH"
    echo "Se ha añadido ZSH_THEME para Powerlevel10k en tu .zshrc."
fi

# Asegurarse de que oh-my-zsh.sh se esté sourceando
if ! grep -q "source \$ZSH/oh-my-zsh.sh" "$ZSHRC_PATH"; then
    echo "source \$ZSH/oh-my-zsh.sh" >> "$ZSHRC_PATH"
    echo "Se ha añadido 'source \$ZSH/oh-my-zsh.sh' a tu .zshrc."
fi

# Cambiar el shell por defecto a Zsh
echo "Cambiando el shell por defecto a Zsh..."
# Verificar si el shell ya es zsh para evitar cambiarlo innecesariamente
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(which zsh)"
    echo "El shell por defecto se ha cambiado a Zsh."
else
    echo "Zsh ya es tu shell por defecto. Saltando cambio."
fi

echo "Configuración de Zsh y Powerlevel10k completada."
echo "Por favor, cierra tu terminal actual y abre una nueva para que los cambios surtan efecto."
echo "La primera vez que inicies Zsh, Powerlevel10k te guiará a través de su asistente de configuración."
