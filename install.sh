#!/bin/bash

# Configurar entorno para el usuario correcto
USER="gdonaire"
USER_DIR="/home/$USER"
FONT_DIR="$USER_DIR/.fonts"
ZSH_CUSTOM="$USER_DIR/.oh-my-zsh/custom"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
FZF_DIR="$USER_DIR/.fzf"

FONTS=(
  "Hack.zip"
)

log() {
  echo -e "[INFO] $1"
}

error_log() {
  echo -e "[ERROR] $1" >&2
}

# Comprobar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  error_log "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

# Configurar entorno para usuario final
export HOME="$USER_DIR"
export USER="$USER"

# Instalar Zsh si falta
if ! command -v zsh &>/dev/null; then
  log "Instalando Zsh..."
  apt update -qq && apt install -y zsh &>/dev/null || {
    error_log "Fallo al instalar Zsh."
    exit 1
  }
else
  log "Zsh ya está instalado."
fi

# Instalar Oh-My-Zsh
if [ ! -f "$USER_DIR/.oh-my-zsh/oh-my-zsh.sh" ]; then
  log "Instalando Oh-My-Zsh..."
  rm -rf "$USER_DIR/.oh-my-zsh" &>/dev/null
  sudo -u "$USER" bash -c 'RUNZSH=no CHSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"' || {
    error_log "Fallo al instalar Oh-My-Zsh."
    exit 1
  }
else
  log "Oh-My-Zsh ya está instalado correctamente."
fi

# Instalar Powerlevel10k
log "Instalando Powerlevel10k..."
if [ ! -d "$P10K_DIR" ]; then
  sudo -u "$USER" git clone --quiet https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" || {
    error_log "Fallo al instalar Powerlevel10k."
    exit 1
  }
else
  log "Powerlevel10k ya está instalado correctamente."
fi

# Instalar bat
log "Instalando bat..."
if ! command -v bat &>/dev/null; then
  wget -q https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb -O /tmp/bat.deb || {
    error_log "Fallo al descargar bat."
    exit 1
  }
  dpkg -i /tmp/bat.deb &>/dev/null || {
    apt-get install -f -y &>/dev/null
    dpkg -i /tmp/bat.deb &>/dev/null || {
      error_log "Fallo al instalar bat desde el archivo .deb."
      exit 1
    }
  }
  rm /tmp/bat.deb
else
  log "bat ya está instalado."
fi

# Instalar lsd
log "Instalando lsd..."
if ! command -v lsd &>/dev/null; then
  apt install -y lsd &>/dev/null || {
    error_log "Fallo al instalar lsd."
    exit 1
  }
else
  log "lsd ya está instalado."
fi

# Instalar fzf
log "Instalando fzf..."
if [ ! -d "$FZF_DIR" ]; then
  sudo -u "$USER" git clone --quiet --depth 1 https://github.com/junegunn/fzf.git "$FZF_DIR" || {
    error_log "Fallo al clonar el repositorio de fzf."
    exit 1
  }
  sudo -u "$USER" bash -c "$FZF_DIR/install --all" &>/dev/null || {
    error_log "Fallo al instalar fzf."
    exit 1
  }
else
  log "fzf ya está instalado."
fi

# Configurar Zsh como shell predeterminado
if [ "$SHELL" != "$(which zsh)" ]; then
  log "Cambiando el shell predeterminado a Zsh..."
  chsh -s "$(which zsh)" "$USER" &>/dev/null || error_log "Fallo al cambiar el shell predeterminado."
else
  log "El shell predeterminado ya es Zsh."
fi

log "Instalación completada. Reinicia la terminal para aplicar los cambios."
