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

# Instalar o reinstalar Oh-My-Zsh
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

# Instalar plugins
PLUGINS=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search fzf)
REPOS=(
  "https://github.com/zsh-users/zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-syntax-highlighting"
  "https://github.com/zsh-users/zsh-completions"
  "https://github.com/zsh-users/zsh-history-substring-search"
)

for i in "${!PLUGINS[@]}"; do
  if [ "${PLUGINS[i]}" != "fzf" ]; then
    if [ ! -d "$ZSH_CUSTOM/plugins/${PLUGINS[i]}" ]; then
      log "Instalando plugin ${PLUGINS[i]}..."
      sudo -u "$USER" git clone --quiet "${REPOS[i]}" "$ZSH_CUSTOM/plugins/${PLUGINS[i]}" || {
        error_log "Fallo al instalar el plugin ${PLUGINS[i]}."
      }
    fi
  fi
done

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

# Configurar FZF_BASE en .zshrc
if ! grep -q "export FZF_BASE=" "$USER_DIR/.zshrc"; then
  echo "export FZF_BASE=\"$FZF_DIR\"" >> "$USER_DIR/.zshrc"
  log "FZF_BASE configurado en .zshrc."
fi

# Configurar Powerlevel10k en .zshrc
if ! grep -q "powerlevel10k/powerlevel10k" "$USER_DIR/.zshrc"; then
  log "Configurando Powerlevel10k en .zshrc..."
  echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> "$USER_DIR/.zshrc"
else
  log "Powerlevel10k ya está configurado en .zshrc."
fi

# Configurar ~/.zshrc
log "Copiando archivo .zshrc preconfigurado..."
if [ -f ".zshrc" ]; then
  # Copiar el archivo preconfigurado
  sudo -u "$USER" cp ".zshrc" "$USER_DIR/.zshrc"
  
  # Añadir configuraciones necesarias si faltan
  if ! grep -q "source $USER_DIR/.oh-my-zsh/oh-my-zsh.sh" "$USER_DIR/.zshrc"; then
    echo "source $USER_DIR/.oh-my-zsh/oh-my-zsh.sh" >> "$USER_DIR/.zshrc"
  fi
  if ! grep -q "export FZF_BASE=" "$USER_DIR/.zshrc"; then
    echo "export FZF_BASE=\"$FZF_DIR\"" >> "$USER_DIR/.zshrc"
  fi
else
  error_log "No se encontró el archivo zshrc/.zshrc. Se usará una configuración básica."
  {
    echo "source $USER_DIR/.oh-my-zsh/oh-my-zsh.sh"
    echo "export FZF_BASE=\"$FZF_DIR\""
    echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\""
  } > "$USER_DIR/.zshrc"
fi

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
