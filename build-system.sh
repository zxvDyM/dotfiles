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
    clang gcc gdb nasm fasm \
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
# echo "Clonando configuraciones de dotfiles desde GitHub..."
# IMPORTANTE: Reemplaza <TU_USUARIO> y <TU_REPOSITORIO> con tus datos reales.
# Si tu repositorio es privado, necesitarás configurar SSH keys o usar un Personal Access Token.
# Se asume que el repositorio es https://github.com/zxvDyM/dotfiles.git
# git clone https://github.com/zxvDyM/dotfiles.git ~/.dotfiles

echo "Creando enlaces simbólicos para dotfiles..."
# Asegúrate de que las carpetas de destino existen
mkdir -p ~/.config/i3
mkdir -p ~/.config/kitty
# Agrega aquí cualquier otra carpeta de configuración necesaria, por ejemplo, para dmenu si tienes config

# Enlace para Emacs
ln -sf ~/.dotfiles/Emacs/emacs ~/.emacs

# Enlace para i3 (ajusta la ruta si tu config de i3 no está en ~/.dotfiles/i3/config)
if [ -f ~/.dotfiles/i3/config ]; then
    ln -sf ~/.dotfiles/i3/config ~/.config/i3/config
else
    echo "Advertencia: No se encontró la configuración de i3 en ~/.dotfiles/i3/config. Asegúrate de añadirla a tu repositorio."
fi

# Enlace para kitty (ajusta la ruta)
if [ -f ~/.dotfiles/kitty/kitty.conf ]; then
    ln -sf ~/.dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
else
    echo "Advertencia: No se encontró la configuración de kitty en ~/.dotfiles/kitty/kitty.conf. Asegúrate de añadirla a tu repositorio."
fi

# Si tienes un .bashrc en tu repo
if [ -f ~/.dotfiles/.bashrc ]; then
    ln -sf ~/.dotfiles/.bashrc ~/.bashrc
else
    echo "Advertencia: No se encontró .bashrc en tu repositorio. Puedes crearlo manualmente o añadirlo a tus dotfiles."
fi

# Instalar la fuente Iosevka
echo "Instalando la fuente Iosevka..."
# Asumiendo que la carpeta 'Font/Iosevka' está dentro del repositorio clonado
if [ -d ~/.dotfiles/Font/Iosevka ]; then
    cd ~/.dotfiles/Font/Iosevka
    mkdir -p ~/.local/share/fonts
    cp *.ttf ~/.local/share/fonts/
    fc-cache -fv
    cd ~ # Volver al directorio home
else
    echo "Error: El directorio ~/.dotfiles/Font/Iosevka no existe dentro del repositorio clonado. Asegúrate de que la estructura es correcta."
    exit 1 # Salir si la fuente no se puede instalar
fi

# Copiar gf2 (si es necesario y el archivo existe en el repo)
echo "Copiando gf2 (si es necesario y el archivo existe en el repo)..."
if [ -f ~/.dotfiles/gf/gf/gf2 ]; then
    cp ~/.dotfiles/gf/gf/gf2 ~/.gf2
    chmod +x ~/.gf2 # Dar permisos de ejecución si es un script/binario
else
    echo "Advertencia: El archivo ~/.dotfiles/gf/gf/gf2 no se encontró en el repositorio. Saltando la copia de gf2."
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
