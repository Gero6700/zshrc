#!/bin/bash
# Stack "devops" opcional: kubectl, helm, k9s, terraform, ansible, go, gh CLI,
# yq y krew. Se instala solo si INSTALL_PROFILE=full (ver .env.example).

install_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    log "kubectl ya está instalado."
    return
  fi
  log "Instalando kubectl (canal v${K8S_CHANNEL})..."
  mkdir -p /etc/apt/keyrings
  curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_CHANNEL}/deb/Release.key" \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_CHANNEL}/deb/ /" \
    > /etc/apt/sources.list.d/kubernetes.list
  apt-get update -qq
  apt_install kubectl || warn "Fallo al instalar kubectl."
}

install_helm() {
  if command -v helm >/dev/null 2>&1; then
    log "helm ya está instalado."
    return
  fi
  log "Instalando helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    || warn "Fallo al instalar helm."
}

install_k9s() {
  if command -v k9s >/dev/null 2>&1; then
    log "k9s ya está instalado."
    return
  fi
  local tag
  tag="$(latest_github_tag derailed/k9s)"
  [ -n "$tag" ] || { warn "No se pudo consultar la última versión de k9s."; return; }
  local url="https://github.com/derailed/k9s/releases/download/${tag}/k9s_Linux_${ARCH}.tar.gz"
  local tmp
  tmp="$(mktemp -d)"
  log "Instalando k9s ${tag}..."
  if curl -fsSL "$url" -o "$tmp/k9s.tar.gz"; then
    tar -xzf "$tmp/k9s.tar.gz" -C "$tmp" k9s
    install -m 755 "$tmp/k9s" /usr/local/bin/k9s
  else
    warn "Fallo al descargar k9s desde $url."
  fi
  rm -rf "$tmp"
}

install_yq() {
  if command -v yq >/dev/null 2>&1; then
    log "yq ya está instalado."
    return
  fi
  local tag
  tag="$(latest_github_tag mikefarah/yq)"
  [ -n "$tag" ] || { warn "No se pudo consultar la última versión de yq."; return; }
  log "Instalando yq ${tag}..."
  curl -fsSL "https://github.com/mikefarah/yq/releases/download/${tag}/yq_linux_${ARCH}" -o /usr/local/bin/yq \
    && chmod 755 /usr/local/bin/yq \
    || warn "Fallo al descargar yq."
}

install_go() {
  if command -v go >/dev/null 2>&1; then
    log "go ya está instalado."
    return
  fi
  local version
  version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
  [ -n "$version" ] || { warn "No se pudo determinar la última versión de Go."; return; }
  local url="https://go.dev/dl/${version}.linux-${ARCH}.tar.gz"
  local tmp
  tmp="$(mktemp -d)"
  log "Instalando Go (${version})..."
  if curl -fsSL "$url" -o "$tmp/go.tar.gz"; then
    rm -rf /usr/local/go
    tar -C /usr/local -xzf "$tmp/go.tar.gz"
    ln -sf /usr/local/go/bin/go /usr/local/bin/go
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
  else
    warn "Fallo al descargar Go desde $url."
  fi
  rm -rf "$tmp"
}

install_gh_cli() {
  if command -v gh >/dev/null 2>&1; then
    log "gh CLI ya está instalado."
    return
  fi
  log "Instalando GitHub CLI (gh)..."
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list
  apt-get update -qq
  apt_install gh || warn "Fallo al instalar gh CLI."
}

install_terraform_binary_fallback() {
  local version
  version="$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform | grep -o '"current_version":"[^"]*' | cut -d'"' -f4)"
  [ -n "$version" ] || { warn "No se pudo determinar la última versión de Terraform."; return; }
  local url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_${ARCH}.zip"
  local tmp
  tmp="$(mktemp -d)"
  if curl -fsSL "$url" -o "$tmp/terraform.zip"; then
    unzip -o -q "$tmp/terraform.zip" -d "$tmp"
    install -m 755 "$tmp/terraform" /usr/local/bin/terraform
  else
    warn "Fallo al descargar Terraform desde $url."
  fi
  rm -rf "$tmp"
}

install_terraform() {
  if command -v terraform >/dev/null 2>&1; then
    log "terraform ya está instalado."
    return
  fi
  log "Instalando terraform..."
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${OS_CODENAME} main" \
    > /etc/apt/sources.list.d/hashicorp.list
  apt-get update -qq
  if ! apt_install terraform 2>/dev/null; then
    warn "El repositorio de HashiCorp no cubre todavía '${OS_CODENAME}'; instalando el binario oficial en su lugar."
    rm -f /etc/apt/sources.list.d/hashicorp.list
    install_terraform_binary_fallback
  fi
}

install_ansible() {
  if command -v ansible >/dev/null 2>&1; then
    log "ansible ya está instalado."
    return
  fi
  apt_update_once
  log "Instalando ansible..."
  apt_install ansible || warn "Fallo al instalar ansible."
}

install_krew() {
  local krew_root="$TARGET_HOME/.krew"
  if [ -x "$krew_root/bin/kubectl-krew" ]; then
    log "krew ya está instalado."
    return
  fi
  command -v kubectl >/dev/null 2>&1 || { warn "kubectl no está disponible; se omite krew."; return; }
  log "Instalando krew para $TARGET_USER..."
  run_as_user '
    set -e
    cd "$(mktemp -d)"
    KREW="krew-linux_'"$ARCH"'"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
    tar zxf "${KREW}.tar.gz"
    "./${KREW}" install krew
  ' || warn "Fallo al instalar krew."
}

install_devops_stack() {
  apt_update_once
  install_kubectl
  install_helm
  install_k9s
  install_yq
  install_go
  install_gh_cli
  install_terraform
  install_ansible
  install_krew
  ok "Stack devops (kubectl, helm, k9s, terraform, ansible, go, gh, yq, krew) instalado."
}
