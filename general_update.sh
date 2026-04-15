#!/usr/bin/env bash

function update_flatpak_snap() {
    if command -v flatpak &> /dev/null; then
        echo "Flatpak is installed. Updating Flatpak packages..."
        sudo flatpak update -y
    fi

    if command -v snap &> /dev/null; then
        echo "Snap is installed. Updating Snap packages..."
        sudo snap refresh
    fi
}

function update_omz() {
    if [[ -d "$HOME/.oh-my-zsh" ]] && command -v omz >/dev/null 2>&1; then
        export ZSH="$HOME/.oh-my-zsh"
        source "$ZSH/oh-my-zsh.sh"
        omz update
    fi
}

function update_debian() {
    sudo apt-get update
    sudo apt-get dist-upgrade -y
    sudo apt-get autoremove -y
    update_flatpak_snap
    update_omz
}

function update_macos() {
    if command -v softwareupdate >/dev/null 2>&1; then
        sudo softwareupdate -i -a
    fi
    update_omz
    if command -v brew >/dev/null 2>&1; then
        brew update
        brew upgrade
        brew cleanup
    fi
}

function update() {
    # Update repository in a subshell so the caller's cwd is preserved
    (
        cd "$HOME/.unix_setup" || exit 1
        echo "Updating .unix_setup repository..."
        git pull || exit 1
    ) || return 1

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS system detected"
        update_macos
    else
        echo "Debian/Ubuntu system detected"
        update_debian
    fi
}
