# Alias generales. Cosas específicas de una máquina concreta van en
# ~/.zshrc.local, no aquí.

# bat/fd en Debian/Ubuntu se instalan como batcat/fdfind; install.sh crea
# symlinks en /usr/local/bin, pero si por lo que sea no existen, caemos aquí.
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi
alias catt='bat'

if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias lt='ls --tree'
fi
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'

# El binario oficial de Helix ya se llama "hx" (lo instala lib/helix.sh),
# así que no hace falta ningún alias para el editor.

command -v kubectl >/dev/null 2>&1 && alias k='kubectl'
command -v kubectl >/dev/null 2>&1 && alias port-argo='kubectl port-forward svc/argocd-server -n argocd 8080:443'
