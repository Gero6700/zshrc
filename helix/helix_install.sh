#!/bin/bash

# Configuración del entorno
USER="gdonaire"
USER_DIR="/home/$USER"
CONFIG_DIR="$USER_DIR/.config/helix"
THEME_REPO="https://github.com/Gero6700/zshrc.git"
HELEX_REPO_DIR="$USER_DIR/zshrc/helix"

log() {
  echo -e "[INFO] $1"
}

error_log() {
  echo -e "[ERROR] $1" >&2
}

# Comprobar permisos
if [ "$EUID" -ne 0 ]; then
  error_log "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

# Instalar Helix usando PPA
log "Añadiendo el repositorio PPA para Helix..."
if ! grep -q "^deb .*/maveonair/helix-editor" /etc/apt/sources.list.d/* &>/dev/null; then
  add-apt-repository -y ppa:maveonair/helix-editor &>/dev/null || {
    error_log "Fallo al añadir el repositorio PPA."
    exit 1
  }
else
  log "El repositorio PPA ya está configurado."
fi

log "Actualizando índices de paquetes..."
apt update -qq || {
  error_log "Fallo al actualizar los índices de paquetes."
  exit 1
}

log "Instalando Helix..."
apt install -y helix || {
  error_log "Fallo al instalar Helix."
  exit 1
}

# Clonar tu repositorio si no existe
if [ ! -d "$HELEX_REPO_DIR" ]; then
  log "Clonando el repositorio de configuración de Helix desde GitHub..."
  git clone "$THEME_REPO" "$HELEX_REPO_DIR" || {
    error_log "Fallo al clonar el repositorio de configuración de Helix."
    exit 1
  }
else
  log "El repositorio de configuración de Helix ya existe."
fi

# Copiar archivos de configuración y temas
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

# Verificar la instalación de Helix
log "Verificando la instalación de Helix..."
if command -v hx &>/dev/null; then
  log "Helix instalado correctamente."
else
  error_log "No se pudo verificar la instalación de Helix."
  exit 1
fi

log "Instalación y configuración de Helix completada. ¡Disfruta!"
