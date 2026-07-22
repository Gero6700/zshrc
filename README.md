## 🖥 ¿Qué es esto?

Bootstrap para dejar una terminal lista para trabajar en cualquier servidor
**Debian 12/13** o **Ubuntu Server** recién instalado: clonas el repo, ejecutas
`install.sh` y te encuentras con el mismo entorno que uso a diario (zsh +
Powerlevel10k, Helix, y las herramientas CLI/devops habituales).

Incluye:

- **Zsh + Oh My Zsh + Powerlevel10k**, con los plugins y el prompt que uso yo.
- **Helix** como editor, con mi `config.toml`.
- Herramientas CLI de siempre: `bat`, `lsd`, `ripgrep`, `fd`, `fzf`, `tmux`,
  `htop`/`btop`, `ncdu`, `tree`, `jq`, `mtr`, `direnv`.
- Opcionalmente (perfil `full`, el de por defecto), un stack devops:
  `kubectl`, `helm`, `k9s`, `terraform`, `ansible`, `go`, `gh` (GitHub CLI),
  `yq` y `krew`.

Todo se instala a la última versión disponible (repos oficiales de apt o
última release de GitHub) en vez de con versiones fijas en el script, así que
no debería quedarse desactualizado con el tiempo.

## 🚀 Instalación

Solo necesitas un Debian 12/13 o Ubuntu Server con `sudo`:

```bash
git clone https://github.com/Gero6700/zshrc
cd zshrc
sudo ./install.sh
```

Por defecto instala todo (perfil `full`) para el usuario que ha invocado
`sudo`. Si quieres ajustar algo, copia `.env.example` a `.env` antes de
ejecutar el script:

```bash
cp .env.example .env
$EDITOR .env
sudo ./install.sh
```

Variables disponibles en `.env`:

| Variable          | Por defecto        | Qué hace |
|-------------------|---------------------|----------|
| `TARGET_USER`     | usuario de `sudo`   | Usuario para el que se instalan los dotfiles. Solo hace falta si ejecutas el script como root sin `sudo`. |
| `INSTALL_PROFILE` | `full`              | `full` instala también el stack devops; `base` se queda solo con shell + Helix, para servidores más ligeros. |
| `K8S_CHANNEL`     | `1.31`              | Canal (minor) del repo oficial de paquetes de `kubectl`. |
| `GIT_USER_NAME` / `GIT_USER_EMAIL` | vacío | Si los rellenas, se configuran como identidad global de git. Si los dejas en blanco, no se toca la configuración de git. |

El script es idempotente: puedes volver a ejecutar `sudo ./install.sh` y solo
instalará/actualizará lo que falte.

## 🖋 Personalizar

- **Prompt/plugins de zsh**: edita `dotfiles/zshrc` y `dotfiles/aliases.zsh`
  en el repo, o directamente `~/.zshrc` una vez instalado.
- **Helix**: la configuración vive en `helix/config/config.toml`.
- **Cosas propias de una máquina** (alias con rutas o IPs concretas, un
  kubeconfig personal, un mount de una NAS...) van en `~/.zshrc.local`, que
  `install.sh` crea vacío la primera vez y nunca sobrescribe. Es el sitio
  para todo lo que no tenga sentido en un repo público.

## 🧩 Estructura del repo

```
install.sh          # entrypoint: detecta distro/arquitectura y orquesta los módulos
lib/common.sh        # logging, detección de OS/arch, resolución del usuario destino
lib/shell.sh          # zsh + oh-my-zsh + p10k + herramientas CLI base
lib/helix.sh          # editor Helix (release oficial de GitHub, amd64/arm64)
lib/devops.sh         # stack opcional: kubectl, helm, k9s, terraform, ansible, go, gh, yq, krew
dotfiles/             # .zshrc, aliases.zsh y .p10k.zsh que se copian al $HOME
helix/config/         # config.toml de Helix
.env.example          # plantilla de configuración
```

## 🤝 Contribuciones

Si tienes sugerencias o mejoras, ¡bienvenidas! Abre un pull request.
