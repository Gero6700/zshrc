#!/bin/bash

USER_DIR="/home/gdonaire"
USER="gdonaire"
FONT_DIR="$USER_DIR/.fonts"
ZSH_CUSTOM="$USER_DIR/.oh-my-zsh/custom"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

FONTS=(
  "Hack.zip"
  "Roboto Mono Nerd Font Complete.ttf"
  "DejaVu Sans Mono Nerd Font Complete.ttf"
)

log() {
  echo -e "[INFO] $1"
}

error_log() {
  echo -e "[ERROR] $1" >&2
}

# Verificar permisos
if [ "$EUID" -ne 0 ]; then
  error_log "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

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

# Instalar o reinstalar Oh-My-Zsh
if [ ! -f "$USER_DIR/.oh-my-zsh/oh-my-zsh.sh" ]; then
  log "Instalando Oh-My-Zsh..."
  rm -rf "$USER_DIR/.oh-my-zsh" &>/dev/null
  RUNZSH=no CHSH=no sh -c "$(wget -q -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &>/dev/null || {
    error_log "Fallo al instalar Oh-My-Zsh."
    exit 1
  }
else
  log "Oh-My-Zsh ya está instalado correctamente."
fi

# Instalar plugins
PLUGINS=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search)
REPOS=(
  "https://github.com/zsh-users/zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-syntax-highlighting"
  "https://github.com/zsh-users/zsh-completions"
  "https://github.com/zsh-users/zsh-history-substring-search"
)

for i in "${!PLUGINS[@]}"; do
  if [ ! -d "$ZSH_CUSTOM/plugins/${PLUGINS[i]}" ]; then
    log "Instalando plugin ${PLUGINS[i]}..."
    git clone --quiet "${REPOS[i]}" "$ZSH_CUSTOM/plugins/${PLUGINS[i]}" || {
      error_log "Fallo al instalar el plugin ${PLUGINS[i]}."
    }
  fi
done

# Instalar Powerlevel10k
log "Instalando Powerlevel10k..."
if [ ! -d "$P10K_DIR" ]; then
  # Descargar Powerlevel10k
  git clone --quiet https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" || {
    error_log "Fallo al instalar Powerlevel10k."
    exit 1
  }
else
  log "Powerlevel10k ya está instalado correctamente."
fi

# Asegurarse de que Powerlevel10k se ha configurado correctamente en .zshrc
if ! grep -q "powerlevel10k/powerlevel10k" "$USER_DIR/.zshrc"; then
  log "Configurando Powerlevel10k en .zshrc..."
  echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> "$USER_DIR/.zshrc"
else
  log "Powerlevel10k ya está configurado en .zshrc."
fi

# Configurar ~/.zshrc
log "Actualizando configuraciones en .zshrc..."
{
  echo "source $USER_DIR/.oh-my-zsh/oh-my-zsh.sh"
} >>"$USER_DIR/.zshrc"

# Instalar Nerd Fonts si faltan
log "Instalando Nerd Fonts si faltan..."
mkdir -p "$FONT_DIR" &>/dev/null
for FONT in "${FONTS[@]}"; do
  FONT_PATH="$FONT_DIR/$FONT"
  if [ ! -f "$FONT_PATH" ]; then
    log "Descargando fuente $FONT..."
    if [ "$FONT" == "Hack.zip" ]; then
      wget -q -O "$FONT_DIR/Hack.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip" || {
        error_log "Fallo al descargar la fuente Hack Regular Nerd Font Complete.ttf."
        continue
      }
      unzip -o "$FONT_DIR/Hack.zip" -d "$FONT_DIR/" &>/dev/null || {
        error_log "Fallo al descomprimir Hack.zip."
        continue
      }
      rm "$FONT_DIR/Hack.zip" || {
        error_log "Fallo al eliminar el archivo Hack.zip."
        continue
      }
    else
      wget -q "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/${FONT// /%20}/Regular/complete/$FONT" -P "$FONT_DIR/" || {
        error_log "Fallo al descargar la fuente $FONT."
        continue
      }
    fi
  fi
done

# Regenerar caché de fuentes
log "Regenerando caché de fuentes..."
fc-cache -fv &>/dev/null || error_log "Fallo al regenerar la caché de fuentes."

# Cambiar shell a Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
  log "Cambiando el shell predeterminado a Zsh..."
  chsh -s "$(which zsh)" "$USER" &>/dev/null || error_log "Fallo al cambiar el shell predeterminado."
else
  log "El shell predeterminado ya es Zsh."
fi

log "Instalación completada. Reinicia la terminal para aplicar los cambios."
