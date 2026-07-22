#!/bin/bash
# Funciones compartidas por todos los módulos de install.sh:
# logging, detección de distro/arquitectura y resolución del usuario destino.

C_RESET='\033[0m'
C_BLUE='\033[1;34m'
C_YELLOW='\033[1;33m'
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'

log()   { echo -e "${C_BLUE}[INFO]${C_RESET} $1"; }
warn()  { echo -e "${C_YELLOW}[WARN]${C_RESET} $1" >&2; }
error() { echo -e "${C_RED}[ERROR]${C_RESET} $1" >&2; }
ok()    { echo -e "${C_GREEN}[OK]${C_RESET} $1"; }

die() {
  error "$1"
  exit 1
}

require_root() {
  [ "$EUID" -eq 0 ] || die "Ejecuta el script con sudo: sudo ./install.sh"
}

# Detecta distro (Debian/Ubuntu) y arquitectura (amd64/arm64).
# Rellena: OS_ID, OS_CODENAME, OS_VERSION_ID, ARCH
detect_platform() {
  [ -r /etc/os-release ] || die "No se encuentra /etc/os-release: no parece un sistema Debian/Ubuntu."
  # shellcheck disable=SC1091
  . /etc/os-release

  OS_ID="$ID"
  OS_ID_LIKE="${ID_LIKE:-}"
  OS_CODENAME="${VERSION_CODENAME:-}"
  OS_VERSION_ID="${VERSION_ID:-}"

  case "$OS_ID $OS_ID_LIKE" in
    *debian*|*ubuntu*) : ;;
    *) die "Distro no soportada ($PRETTY_NAME). Este script está pensado para Debian 12/13 y Ubuntu Server." ;;
  esac

  command -v apt-get >/dev/null 2>&1 || die "No se encuentra apt-get. Este script requiere una base Debian/Ubuntu."

  case "$(uname -m)" in
    x86_64) ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *) die "Arquitectura no soportada: $(uname -m)" ;;
  esac

  log "Detectado: ${PRETTY_NAME:-$OS_ID} (${OS_CODENAME:-sin codename}) / $ARCH"
}

# Resuelve el usuario "normal" para el que se instalan los dotfiles.
# Prioridad: TARGET_USER (de .env) > SUDO_USER > error.
resolve_target_user() {
  TARGET_USER="${TARGET_USER:-${SUDO_USER:-}}"
  if [ -z "$TARGET_USER" ] || [ "$TARGET_USER" = "root" ]; then
    die "No se pudo determinar el usuario destino. Ejecuta con 'sudo ./install.sh' desde tu usuario normal, o define TARGET_USER en .env."
  fi
  TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
  [ -n "$TARGET_HOME" ] && [ -d "$TARGET_HOME" ] || die "El usuario '$TARGET_USER' no existe o no tiene home."
}

# Ejecuta un comando como TARGET_USER, con su HOME correcto.
run_as_user() {
  sudo -u "$TARGET_USER" -H env HOME="$TARGET_HOME" bash -c "$1"
}

apt_install() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

apt_update_once() {
  if [ -z "${_APT_UPDATED:-}" ]; then
    log "Actualizando índices de apt..."
    apt-get update -qq
    _APT_UPDATED=1
  fi
}

# Descarga el binario de una release de GitHub (último tag por defecto) y lo deja en $2.
# Uso: github_release_asset <owner/repo> <patrón-con-{version}-y-{arch}> <archivo-destino> [arch_amd64] [arch_arm64]
latest_github_tag() {
  local repo="$1"
  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'
}

backup_if_exists() {
  local f="$1"
  [ -e "$f" ] && [ ! -L "$f" ] && cp -a "$f" "${f}.bak.$(date +%s)" 2>/dev/null
  return 0
}
