#!/bin/bash
# Base de shell: zsh + oh-my-zsh + Powerlevel10k + plugins, herramientas CLI
# básicas por apt, y despliegue de los dotfiles del repo.

install_base_packages() {
  apt_update_once

  local required_pkgs=(zsh git curl wget ca-certificates gnupg lsb-release unzip locales)
  local optional_pkgs=(bat lsd ripgrep fd-find tree htop btop ncdu tmux jq mtr-tiny direnv)

  log "Instalando paquetes imprescindibles (zsh, git, curl...)..."
  apt_install "${required_pkgs[@]}" || die "Fallo instalando paquetes base imprescindibles."

  # Uno por uno: si un paquete no existe en esta versión concreta de la
  # distro (p. ej. btop en alguna LTS más antigua), que no tumbe el resto.
  log "Instalando utilidades CLI (bat, lsd, ripgrep, fd, tmux, htop/btop...)..."
  local pkg
  for pkg in "${optional_pkgs[@]}"; do
    apt_install "$pkg" || warn "No se pudo instalar '$pkg' (puede que no exista en esta versión de la distro)."
  done

  # Debian/Ubuntu instalan bat y fd con otro nombre de binario para evitar
  # choques de nombre con paquetes previos (batcat/fdfind). Creamos symlinks
  # en /usr/local/bin para poder usar 'bat' y 'fd' tal cual.
  if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" /usr/local/bin/bat
  fi
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi

  # locale usada en el .zshrc (en_US.UTF-8)
  if ! locale -a 2>/dev/null | grep -qi 'en_US.utf8'; then
    log "Generando locale en_US.UTF-8..."
    sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen 2>/dev/null
    grep -q '^en_US.UTF-8 UTF-8' /etc/locale.gen 2>/dev/null || echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
    locale-gen >/dev/null 2>&1 || warn "No se pudo generar la locale en_US.UTF-8 automáticamente."
  fi
}

install_oh_my_zsh() {
  local zsh_dir="$TARGET_HOME/.oh-my-zsh"
  local custom="$zsh_dir/custom"

  if [ ! -f "$zsh_dir/oh-my-zsh.sh" ]; then
    log "Instalando Oh My Zsh para $TARGET_USER..."
    run_as_user "RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"" \
      || die "Fallo al instalar Oh My Zsh."
  else
    log "Oh My Zsh ya está instalado."
  fi

  clone_or_update "$custom/themes/powerlevel10k" https://github.com/romkatv/powerlevel10k.git
  clone_or_update "$custom/plugins/zsh-autosuggestions" https://github.com/zsh-users/zsh-autosuggestions.git
  clone_or_update "$custom/plugins/zsh-syntax-highlighting" https://github.com/zsh-users/zsh-syntax-highlighting.git
}

clone_or_update() {
  local dest="$1" repo="$2"
  if [ -d "$dest/.git" ]; then
    log "Actualizando $(basename "$dest")..."
    run_as_user "git -C '$dest' pull --quiet" || warn "No se pudo actualizar $dest."
  else
    log "Clonando $(basename "$dest")..."
    run_as_user "git clone --quiet --depth 1 '$repo' '$dest'" || die "Fallo al clonar $repo."
  fi
}

install_fzf() {
  local fzf_dir="$TARGET_HOME/.fzf"
  if [ ! -d "$fzf_dir" ]; then
    log "Instalando fzf..."
    run_as_user "git clone --quiet --depth 1 https://github.com/junegunn/fzf.git '$fzf_dir'" || die "Fallo al clonar fzf."
    # --no-update-rc: nosotros ya sourceamos ~/.fzf.zsh desde dotfiles/zshrc,
    # así que no dejamos que el instalador toque (ni pregunte por) el .zshrc.
    run_as_user "'$fzf_dir/install' --key-bindings --completion --no-update-rc" || die "Fallo al instalar fzf."
  else
    log "fzf ya está instalado."
  fi
}

deploy_dotfiles() {
  local repo_dir
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  log "Desplegando dotfiles en $TARGET_HOME..."

  backup_if_exists "$TARGET_HOME/.zshrc"
  cp "$repo_dir/dotfiles/zshrc" "$TARGET_HOME/.zshrc"

  mkdir -p "$TARGET_HOME/.config/zsh"
  cp "$repo_dir/dotfiles/aliases.zsh" "$TARGET_HOME/.config/zsh/aliases.zsh"

  backup_if_exists "$TARGET_HOME/.p10k.zsh"
  cp "$repo_dir/dotfiles/p10k.zsh" "$TARGET_HOME/.p10k.zsh"

  # Punto de extensión para overrides propios de esta máquina (claves ssh,
  # alias de kubeconfigs, mounts de NAS...) que no queremos versionar en un
  # repo público. install.sh nunca sobrescribe este fichero si ya existe.
  [ -f "$TARGET_HOME/.zshrc.local" ] || touch "$TARGET_HOME/.zshrc.local"

  chown -R "$TARGET_USER":"$TARGET_USER" \
    "$TARGET_HOME/.zshrc" "$TARGET_HOME/.p10k.zsh" \
    "$TARGET_HOME/.config/zsh" "$TARGET_HOME/.zshrc.local"
}

set_default_shell() {
  local zsh_bin
  zsh_bin="$(command -v zsh)"
  if [ "$(getent passwd "$TARGET_USER" | cut -d: -f7)" != "$zsh_bin" ]; then
    log "Cambiando el shell por defecto de $TARGET_USER a zsh..."
    chsh -s "$zsh_bin" "$TARGET_USER" || warn "No se pudo cambiar el shell por defecto."
  else
    log "zsh ya es el shell por defecto de $TARGET_USER."
  fi
}

install_shell_stack() {
  install_base_packages
  install_oh_my_zsh
  install_fzf
  deploy_dotfiles
  set_default_shell
  ok "Base de shell (zsh + oh-my-zsh + p10k + herramientas CLI) instalada."
}
