#!/bin/bash

current_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# ZSH main config file
ln -sf "${current_folder}/zshrc" ~/.zshrc

# oh my zsh main theme
ln -sf "${current_folder}/robbyrussell.zsh-theme" ~/.oh-my-zsh/themes/robbyrussell.zsh-theme
