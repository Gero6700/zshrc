#!/bin/bash
# Instala el editor Helix desde las releases oficiales de GitHub (hay .deb
# pero solo para amd64; usando el tarball cubrimos también arm64) y despliega
# la configuración (helix/config/config.toml) del repo.

HELIX_INSTALL_DIR=/opt/helix

install_helix() {
  local hx_dest="$HELIX_INSTALL_DIR"
  local current_version=""

  if [ -x /usr/local/bin/hx ]; then
    current_version="$(/usr/local/bin/hx --version 2>/dev/null | awk '{print $2}')"
  fi

  log "Consultando la última versión de Helix en GitHub..."
  local tag
  tag="$(latest_github_tag helix-editor/helix)" || true
  if [ -z "$tag" ]; then
    warn "No se pudo consultar la última versión de Helix (¿sin acceso a GitHub?). Se omite la instalación de Helix."
    return 0
  fi
  local version="${tag#v}"

  if [ "$current_version" = "$version" ]; then
    log "Helix ya está en la última versión ($version)."
  else
    local hx_arch
    case "$ARCH" in
      amd64) hx_arch=x86_64 ;;
      arm64) hx_arch=aarch64 ;;
    esac
    local asset="helix-${version}-${hx_arch}-linux.tar.xz"
    local url="https://github.com/helix-editor/helix/releases/download/${tag}/${asset}"
    local tmp_dir
    tmp_dir="$(mktemp -d)"

    log "Descargando Helix ${version} (${hx_arch})..."
    if ! curl -fsSL "$url" -o "$tmp_dir/helix.tar.xz"; then
      warn "No se pudo descargar Helix desde $url. Se omite."
      rm -rf "$tmp_dir"
      return 0
    fi

    tar -xJf "$tmp_dir/helix.tar.xz" -C "$tmp_dir"
    local extracted
    extracted="$(find "$tmp_dir" -maxdepth 1 -type d -name 'helix-*' | head -1)"
    [ -n "$extracted" ] || { warn "No se encontró el directorio extraído de Helix."; rm -rf "$tmp_dir"; return 0; }

    rm -rf "$hx_dest"
    mkdir -p "$hx_dest"
    cp -r "$extracted"/. "$hx_dest"/
    ln -sf "$hx_dest/hx" /usr/local/bin/hx
    rm -rf "$tmp_dir"

    # HELIX_RUNTIME es necesario porque el binario no viene instalado vía
    # paquete del sistema: sin esto, Helix no encuentra los grammars/queries.
    cat > /etc/profile.d/helix.sh <<EOF
export HELIX_RUNTIME=$hx_dest/runtime
EOF
    chmod 644 /etc/profile.d/helix.sh

    ok "Helix ${version} instalado en $hx_dest (symlink en /usr/local/bin/hx)."
  fi
}

deploy_helix_config() {
  local repo_dir
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local target_config="$TARGET_HOME/.config/helix"

  log "Desplegando configuración de Helix..."
  mkdir -p "$target_config"
  backup_if_exists "$target_config/config.toml"
  cp "$repo_dir/helix/config/config.toml" "$target_config/config.toml"
  chown -R "$TARGET_USER":"$TARGET_USER" "$target_config"
}

install_helix_stack() {
  install_helix
  deploy_helix_config
  ok "Helix instalado y configurado."
}
