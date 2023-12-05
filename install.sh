#!/bin/bash

#Home directory del usuario
USER=/home/gero

sudo apt install -y zsh

#Install oh-my-zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Oh-my-zsh plugins

#zsh-autosuggestions
if [ -d ~/.config/gero/oh-my-zsh/plugins/zsh-autosuggestions ]; then
    cd ~/.config/gero/oh-my-zsh/plugins/zsh-autosuggestions && git pull
else
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

#zsh-syntax-highlighting
if [ -d ~/.config/gero/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    cd ~/.config/gero/oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/gero/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

#zsh-completions
if [ -d ~/.config/gero/oh-my-zsh/custom/plugins/zsh-completions ]; then
    cd ~/.config/gero/oh-my-zsh/custom/plugins/zsh-completions && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.config/gero/oh-my-zsh/custom/plugins/zsh-completions
fi

#zsh-history-substring-search
if [ -d ~/.config/gero/oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then
    cd ~/.config/gero/oh-my-zsh/custom/plugins/zsh-history-substring-search && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ~/.config/gero/oh-my-zsh/custom/plugins/zsh-history-substring-search
fi

# INSTALL FONTS
sudo apt-get install -y fontconfig

echo -e "Installing Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n"
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/

fc-cache -fv ~/.fonts


#p10k
echo -e "Installing P10K\n"

if [ -d ~/.config/gero/oh-my-zsh/custom/themes/powerlevel10k ]; then
    cd ~/.config/gero/oh-my-zsh/custom/themes/powerlevel10k && git pull
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/gero/oh-my-zsh/custom/themes/powerlevel10k
fi

if [ -d ~/.~/.config/gero/fzf ]; then
    cd ~/.config/gero/fzf && git pull
    ~/.config/gero/fzf/install --all --key-bindings --completion --no-update-rc
else
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/gero/fzf
    ~/.config/gero/fzf/install --all --key-bindings --completion --no-update-rc
fi


#copiar config de github desde un directorio temporal
echo -e "Copy Github Configuration\n"

sudo apt install -y unzip
git clone https://github.com/Gero6700/zshrc /tmp/zsh_temp
cd /tmp/zsh_temp
cp .zshrc ~/
unzip powerlevel10k.zip -d /home/gero/
unzip zsh-syntax-highlighting.zip -d /home/gero/


# source ~/.zshrc
echo -e "\nSudo access is needed to change default shell\n"

if chsh -s $(which zsh) && /bin/zsh -i -c 'omz update'; then
    echo -e "Installation Successful, exit terminal and enter a new session"
else
    echo -e "Something is wrong"
fi
exit