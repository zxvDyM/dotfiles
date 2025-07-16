#!/bin/bash
set -e

echo "🚀 Ejecutando instalación del sistema..."
./void-setup.sh

echo "🌀 Reiniciando para aplicar cambios del sistema..."
read -p "¿Deseas reiniciar ahora? (s/N): " respuesta
if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    sudo reboot
else
    echo "⚠️ Es recomendable reiniciar antes de continuar."
    read -p "¿Deseas continuar con la configuración de Zsh de todos modos? (s/N): " seguir
    if [[ "$seguir" =~ ^[Ss]$ ]]; then
        ./zsh-setup.sh
    else
        echo "🔁 Puedes ejecutar ./zsh-setup.sh manualmente más tarde."
    fi
fi
