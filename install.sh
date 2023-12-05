#!/bin/bash

USER=/home/gero

#Install oh-my-zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Oh-my-zsh plugins

sudo apt install -S zsh-autosuggestions zsh-syntax-highlighting --noconfirm
cp -r /usr/share/zsh/plugins/zsh-autosuggestions/ $USER/.oh-my-zsh/plugins
cp -r /usr/share/zsh/plugins/zsh-syntax-highlighting $USER/.oh-my-zsh/plugins