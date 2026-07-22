#!/bin/bash
# Bootstrap de terminal para Debian 12/13 y Ubuntu Server: zsh + oh-my-zsh +
# Powerlevel10k, herramientas CLI, Helix y (opcional) stack devops.
#
# Uso:
#   git clone https://github.com/Gero6700/zshrc && cd zshrc
#   cp .env.example .env   # opcional, para ajustar el perfil/usuario
#   sudo ./install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"
# shellcheck source=lib/shell.sh
source "$REPO_DIR/lib/shell.sh"
# shellcheck source=lib/helix.sh
source "$REPO_DIR/lib/helix.sh"
# shellcheck source=lib/devops.sh
source "$REPO_DIR/lib/devops.sh"

# Valores por defecto (ver .env.example); un .env en el repo los sobreescribe.
# "base": sin stack de k8s/devops salvo que se pida explícitamente por .env.
INSTALL_PROFILE="base"
K8S_CHANNEL="1.31"
TARGET_USER=""
GIT_USER_NAME=""
GIT_USER_EMAIL=""

if [ -f "$REPO_DIR/.env" ]; then
  log "Cargando configuración desde .env..."
  # shellcheck disable=SC1091
  source "$REPO_DIR/.env"
fi

configure_git_identity() {
  [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ] || return 0
  log "Configurando identidad de git para $TARGET_USER..."
  run_as_user "git config --global user.name '$GIT_USER_NAME'"
  run_as_user "git config --global user.email '$GIT_USER_EMAIL'"
  run_as_user "git config --global init.defaultBranch main"
  run_as_user "git config --global core.editor hx"
}

main() {
  require_root
  detect_platform
  resolve_target_user

  log "Perfil de instalación: $INSTALL_PROFILE | Usuario destino: $TARGET_USER ($TARGET_HOME)"

  install_shell_stack
  install_helix_stack

  case "$INSTALL_PROFILE" in
    full) install_devops_stack ;;
    base) log "Perfil 'base': se omite el stack devops (kubectl/helm/terraform/ansible/go/gh/yq/krew)." ;;
    *) warn "INSTALL_PROFILE='$INSTALL_PROFILE' no reconocido; usa 'full' o 'base'. Se omite el stack devops." ;;
  esac

  configure_git_identity

  ok "Instalación completada."
  log "Cierra sesión y vuelve a entrar (o ejecuta 'zsh') para que $TARGET_USER use el nuevo shell."
  log "Personalizaciones propias de esta máquina: edita $TARGET_HOME/.zshrc.local"
}

main "$@"
