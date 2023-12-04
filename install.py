import os

# Define la URL de tu repositorio de GitHub
repo_url = "https://github.com/Gero6700/zshrc"

# Instalación de zsh y Oh My Zsh
os.system("sudo apt-get install zsh")  # O utiliza el gestor de paquetes correspondiente a tu sistema
os.system("sh -c '$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)'")

# Instalación git y unzip
os.system("sudo apt-get install git")
os.system("sudo apt-get install unzip")

# Clonar repositorio
os.system(f"git clone {repo_url} $HOME/")

# Descomprimir archivos zip de powerlevel10k y zsh-syntax-highlighting
os.system("cd $HOME/powerlevel10k && unzip powerlevel10k.zip")
os.system("cd $HOME/zsh-syntax-highlighting && unzip zsh-syntax-highlighting.zip")

# Copiar archivos de configuración con nombres personalizados
os.system("cp -r $HOME/zshrc_custom_name $HOME/.zshrc")
os.system("cp -r $HOME/powerlevel10k $$HOME/themes/")

# Instalación de plugins fzf y zsh-autosuggestions
os.system("git clone https://github.com/junegunn/fzf.git ~/.fzf")
os.system("~/.fzf/install")
os.system("git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions")

# Cambiar el shell predeterminado a zsh
os.system("chsh -s $(which zsh)")
