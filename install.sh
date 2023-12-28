#!/bin/bash

#Home directory del usuario
USER_DIR=/home/gd2k
USER=gd2k

#Instalar zsh
sudo apt install -y zsh

#Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Oh-my-zsh plugins

#zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

#zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

#zsh-completions
if [ -d ~/.config/${USER}/oh-my-zsh/custom/plugins/zsh-completions ]; then
    cd ~/.config/${USER}/oh-my-zsh/custom/plugins/zsh-completions && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.config/${USER}/oh-my-zsh/custom/plugins/zsh-completions
fi

#zsh-history-substring-search
if [ -d ~/.config/${USER}/oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then
    cd ~/.config/${USER}/oh-my-zsh/custom/plugins/zsh-history-substring-search && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ~/.config/${USER}/oh-my-zsh/custom/plugins/zsh-history-substring-search
fi

# Instalacion de fuentes
sudo apt-get install -y fontconfig

echo -e "Installing Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n"

#HackHack Regular
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf -P ~/.fonts/

#RobotoMono
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/

#DejaVuSansMono
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/

fc-cache -fv ~/.fonts

#Instalacion P10K
echo -e "Installing P10K\n"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

#Instalar fzf
if [ -d ~/.~/.config/${USER}/fzf ]; then
    cd ~/.config/${USER}/fzf && git pull
    ~/.config/${USER}/fzf/install --all --key-bindings --completion --no-update-rc
else
   sudo apt install -y fzf
fi

#Copiar configuracion custom de github
echo -e "Copy Github Configuration\n"

sudo apt install -y unzip
git clone https://github.com/gero6700/zshrc /tmp/zsh_temp
cd /tmp/zsh_temp
cp .zshrc ~/

#Instalar bat
wget https://github.com/sharkdp/bat/releases/download/v0.15.4/bat-musl_0.15.4_amd64.deb /tmp/zsh_temp
cd /tmp/zsh_temp
sudo dpkg -i bat-musl_0.15.4_amd64.deb

# Poner de predeterminada zshrc
echo -e "\nSudo access is needed to change default shell\n"

if chsh -s $(which zsh) && /bin/zsh -i -c 'omz update'; then
    echo -e "Installation Successful, exit terminal and enter a new session"
else
    echo -e "Something is wrong"
fi
exit