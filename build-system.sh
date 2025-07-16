#!/bin/bash
set -e # Detener el script si algún comando falla

echo "Iniciando la configuración del sistema Void Linux..."

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo xbps-install -Syu

# Habilitar servicios esenciales
echo "Habilitando servicios esenciales..."
sudo ln -s /etc/sv/sshd /var/service
sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/elogind /var/service
sudo ln -s /etc/sv/NetworkManager /var/service

# Instalar paquetes necesarios
echo "Instalando paquetes de sistema y desarrollo..."
sudo xbps-install -S \
    xorg \
    lightdm \
    lightdm-gtk-greeter \
    NetworkManager \
    i3 i3status i3lock dmenu \
    emacs-gtk3 \
    clang gcc gdb nasm fasm base-devel \
    unzip \
    kitty \
    polkit \
    elogind-extra \
    git \
    htop tree curl wget \
    -y

# Habilitar el servicio LightDM después de instalarlo
echo "Habilitando LightDM..."
sudo ln -s /etc/sv/lightdm /var/service

# --- Configuración de Dotfiles ---
echo "Clonando configuraciones de dotfiles desde GitHub..."
# IMPORTANTE: Reemplaza <TU_USUARIO> y <TU_REPOSITORIO> con tus datos reales.
# Se asume que el repositorio es https://github.com/zxvDyM/dotfiles.git
# Clonar directamente en ~/.dotfiles
if [ -d ~/.dotfiles ]; then
    echo "El directorio ~/.dotfiles ya existe. Saltando la clonación del repositorio."
else
    git clone https://github.com/zxvDyM/dotfiles.git ~/.dotfiles
    echo "Repositorio dotfiles clonado en ~/.dotfiles"
fi

# Determinar la ruta base de los dotfiles dentro del repositorio clonado
# Si el repositorio tiene una subcarpeta 'dotfiles' (ej. repo/dotfiles/config), la usaremos.
# De lo contrario, usaremos la raíz del repositorio clonado.
DOTFILES_BASE_PATH=~/.dotfiles
if [ -d "$DOTFILES_BASE_PATH/dotfiles" ]; then
    DOTFILES_BASE_PATH="$DOTFILES_BASE_PATH/dotfiles"
    echo "Detectada subcarpeta 'dotfiles' dentro del repositorio. La ruta base es: $DOTFILES_BASE_PATH"
else
    echo "No se detectó una subcarpeta 'dotfiles'. La ruta base es: $DOTFILES_BASE_PATH"
fi


echo "Creando enlaces simbólicos para dotfiles..."
# Asegúrate de que las carpetas de destino existen
mkdir -p ~/.config/i3
mkdir -p ~/.config/kitty

# Enlace para Emacs
ln -sf "$DOTFILES_BASE_PATH/Emacs/emacs" ~/.emacs

# Enlace para i3 (ajusta la ruta si tu config de i3 no está en ~/.dotfiles/i3/config)
if [ -f "$DOTFILES_BASE_PATH/i3/config" ]; then
    ln -sf "$DOTFILES_BASE_PATH/i3/config" ~/.config/i3/config
else
    echo "Advertencia: No se encontró la configuración de i3 en $DOTFILES_BASE_PATH/i3/config. Asegúrate de añadirla a tu repositorio."
fi

# Enlace para kitty y configuración de fuente
if [ -f "$DOTFILES_BASE_PATH/kitty/kitty.conf" ]; then
    ln -sf "$DOTFILES_BASE_PATH/kitty/kitty.conf" ~/.config/kitty/kitty.conf
    echo "Se ha enlazado tu configuración de kitty. Asegúrate de que incluye 'font_family Iosevka Nerd Font' para usar la fuente instalada."
else
    echo "Advertencia: No se encontró la configuración de kitty en $DOTFILES_BASE_PATH/kitty/kitty.conf."
    echo "Creando una configuración de kitty por defecto con Iosevka Nerd Font..."
    mkdir -p ~/.config/kitty
    cat <<EOF > ~/.config/kitty/kitty.conf
# Configuración de Kitty generada por el script de instalación
font_family Iosevka Nerd Font
font_size 12.0
enable_audio_bell no
EOF
    echo "Se ha creado un archivo ~/.config/kitty/kitty.conf por defecto."
fi

# Si tienes un .bashrc en tu repo
if [ -f "$DOTFILES_BASE_PATH/.bashrc" ]; then
    ln -sf "$DOTFILES_BASE_PATH/.bashrc" ~/.bashrc
else
    echo "Advertencia: No se encontró .bashrc en tu repositorio. Puedes crearlo manualmente o añadirlo a tus dotfiles."
fi

# Instalar la fuente Iosevka
echo "Instalando la fuente Iosevka..."
# Asumiendo que la carpeta 'Font/Iosevka' está dentro del repositorio clonado
if [ -d "$DOTFILES_BASE_PATH/Font/Iosevka" ]; then
    cd "$DOTFILES_BASE_PATH/Font/Iosevka"
    mkdir -p ~/.local/share/fonts
    cp *.ttf ~/.local/share/fonts/
    fc-cache -fv
    cd ~ # Volver al directorio home
else
    echo "Error: El directorio $DOTFILES_BASE_PATH/Font/Iosevka no existe dentro del repositorio clonado. Asegúrate de que la estructura es correcta."
    exit 1 # Salir si la fuente no se puede instalar
fi

# Copiar gf2 (si es necesario y el archivo existe en el repo)
echo "Copiando gf2 (si es necesario y el archivo existe en el repo)..."
if [ -f "$DOTFILES_BASE_PATH/gf/gf/gf2" ]; then
    cp "$DOTFILES_BASE_PATH/gf/gf/gf2" ~/.gf2
    chmod +x ~/.gf2 # Dar permisos de ejecución si es un script/binario
else
    echo "Advertencia: El archivo $DOTFILES_BASE_PATH/gf/gf/gf2 no se encontró en el repositorio. Saltando la copia de gf2."
fi

# Configurar .gdbinit
echo "Configurando .gdbinit..."
echo "set breakpoint pending on" > ~/.gdbinit
echo "set disassembly-flavor intel" >> ~/.gdbinit

# Añadir el usuario actual a grupos esenciales
echo "Añadiendo el usuario actual a grupos esenciales (video, audio, input, network)..."
# Usamos "$(whoami)" para obtener el nombre del usuario que ejecuta el script
sudo usermod -aG video,audio,input,network "$(whoami)"

# --- Limpieza ---
echo "Realizando limpieza de archivos temporales..."
rm -rf ~/build-system.sh

echo "Configuración completada. Por favor, reinicia el sistema para aplicar todos los cambios, especialmente los cambios de grupo."
sudo reboot
