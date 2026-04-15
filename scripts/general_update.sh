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
    update_omz

    local brew_bin
    if [[ -x /opt/homebrew/bin/brew ]]; then
        brew_bin=/opt/homebrew/bin/brew
    elif [[ -x /usr/local/bin/brew ]]; then
        brew_bin=/usr/local/bin/brew
    fi

    if [[ -n "$brew_bin" ]]; then
        eval "$("$brew_bin" shellenv)"
        brew update
        brew upgrade
        brew cleanup || echo "Warning: brew cleanup could not remove all old kegs (permission issues on some system packages)"
        brew autoremove
    fi
}

function update() {
    # Update repository in a subshell so the caller's cwd is preserved
    (
        cd "$HOME/.unix_setup" || exit 1
        if git rev-parse --git-dir > /dev/null 2>&1; then
            echo "Updating .unix_setup repository..."
            git pull || echo "Warning: git pull failed, continuing anyway..."
            git submodule update --init --recursive || echo "Warning: submodule update failed, continuing anyway..."
        else
            echo "Warning: $HOME/.unix_setup exists but is not a Git repository, Update .unix_setup/public instead"
            cd "$HOME/.unix_setup/public" || exit 1
            if git rev-parse --git-dir > /dev/null 2>&1; then
                echo "Updating .unix_setup/public repository..."
                git pull || echo "Warning: git pull failed, continuing anyway..."
                git submodule update --init --recursive || echo "Warning: submodule update failed, continuing anyway..."
            fi
        fi
    )

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS system detected"
        update_macos
    else
        echo "Debian/Ubuntu system detected"
        update_debian
    fi
}
