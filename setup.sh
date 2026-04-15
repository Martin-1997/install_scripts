#!/bin/bash

# First, Install all packages and especially zsh

# Second, install oh-my-zsh from https://ohmyz.sh/#install

# Run this script

# Logout and login again


current_folder=$(pwd)

backup_file(){
    # cp ~/.zshrc  ~/.zshrc_before_setup
    cp "$1"  "${1}_before_setup"
}

create_link(){
    # backup_file ~/.zshrc
    # ln -sf ${current_folder}/zsh/zshrc ~/.zshrc
    #backup_file ${1}
    ln -sf ${2} ${1}
}

# ZSH main config file
create_link ~/.zshrc ${current_folder}/config_files/zsh/zshrc

# TMUX config file
create_link ~/.tmux.conf ${current_folder}/config_files/tmux.conf

# oh my zsh main theme
create_link ~/.oh-my-zsh/themes/robbyrussell.zsh-theme ${current_folder}/config_files/zsh/robbyrussell.zsh-theme
