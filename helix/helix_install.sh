#!/bin/bash

# Configuración del entorno
USER="gdonaire"
USER_DIR="/home/$USER"
CONFIG_DIR="$USER_DIR/.config/helix"
THEME_REPO="https://github.com/Gero6700/zshrc.git"
HELEX_REPO_DIR="$USER_DIR/zshrc/helix"
HELIX_VERSION="25.1.1-1"
HELIX_DEB_URL="https://github.com/helix-editor/helix/releases/download/25.01.1/helix_${HELIX_VERSION}_amd64.deb"

log() {
  echo -e "[INFO] $1"
}

error_log() {
  echo -e "[ERROR] $1" >&2
}

# Comprobar permisos de root
if [ "$EUID" -ne 0 ]; then
  error_log "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

# Instalar dependencias necesarias
log "Instalando dependencias necesarias..."
apt update -qq
apt install -y curl git || {
  error_log "Fallo al instalar dependencias."
  exit 1
}

# Descargar el paquete de instalación de Helix
log "Descargando Helix versión $HELIX_VERSION..."
curl -L -o /tmp/helix.deb "$HELIX_DEB_URL" || {
  error_log "Fallo al descargar Helix desde $HELIX_DEB_URL."
  exit 1
}

# Instalar Helix
log "Instalando Helix..."
dpkg -i /tmp/helix.deb || {
  error_log "Fallo al instalar Helix. Intentando corregir dependencias..."
  apt --fix-broken install -y
}

# Clonar el repositorio de configuración si no existe
if [ ! -d "$HELEX_REPO_DIR" ]; then
  log "Clonando el repositorio de configuración de Helix desde GitHub..."
  sudo -u "$USER" git clone "$THEME_REPO" "$HELEX_REPO_DIR" || {
    error_log "Fallo al clonar el repositorio de configuración de Helix."
    exit 1
  }
else
  log "El repositorio de configuración de Helix ya existe."
fi

# Crear directorio de configuración si no existe
mkdir -p "$CONFIG_DIR"

# Copiar archivos de configuración
log "Copiando archivos de configuración y temas de Helix..."
cp -r "$HELEX_REPO_DIR/config" "$CONFIG_DIR" || {
  error_log "Fallo al copiar la configuración de Helix."
  exit 1
}

# Verificar que el archivo de configuración existe
if [ ! -f "$CONFIG_DIR/config.toml" ]; then
  error_log "El archivo config.toml no se encuentra en el directorio de configuración."
  exit 1
fi

# Ajustar permisos para que el usuario pueda acceder a su configuración
chown -R "$USER":"$USER" "$CONFIG_DIR"

# Verificar la instalación de Helix
log "Verificando la instalación de Helix..."
if command -v hx &>/dev/null; then
  log "Helix instalado correctamente."
else
  error_log "No se pudo verificar la instalación de Helix."
  exit 1
fi

log "Instalación y configuración de Helix completada. ¡Disfruta!"
