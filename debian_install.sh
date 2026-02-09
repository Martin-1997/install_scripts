#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--gui] [--flatpak] [--development] [--kde] [--ai] [--omz] [--custom_repo]"
}

want_gui=false
want_flatpak=false
want_development=false
want_kde=false
want_ai=false
want_omz=false
want_custom_repo=false
for arg in "$@"; do
  case "$arg" in
    --gui)
      want_gui=true
      ;;
    --flatpak)
      want_flatpak=true
      ;;
    --development)
      want_development=true
      ;;
    --kde)
      want_kde=true
      ;;
    --ai)
      want_ai=true
      ;;
    --omz)
      want_omz=true
      ;;
    --custom_repo)
      want_custom_repo=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      usage
      exit 1
      ;;
  esac
done

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

sudo apt-get install -y gnupg2
sudo apt-get install -y curl
sudo apt-get install -y nmap
sudo apt-get install -y sudo
sudo apt-get install -y nano
sudo apt-get install -y vim
sudo apt-get install -y tmux
sudo apt-get install -y openvpn
sudo apt-get install -y git
sudo apt-get install -y unzip
sudo apt-get install -y htop
sudo apt-get install -y gcc
sudo apt-get install -y net-tools
sudo apt-get install -y ufw
sudo apt-get install -y zsh
sudo apt-get install -y pyenv
sudo apt-get install -y bat
sudo apt-get install -y wireguard
sudo apt-get install -y wireguard-tools
sudo apt-get install -y iperf3
sudo apt-get install -y traceroute
sudo apt-get install -y iftop
sudo apt-get install -y dnsutils
sudo apt-get install -y tcpdump

# Change shell to zsh (root and martin)
zsh_path="$(command -v zsh)"
chsh -s "$zsh_path"

# Set zsh as default shell for root
sudo chsh -s "$zsh_path"
# Set zsh as default shell for the user martin
sudo chsh -s "$zsh_path" martin

bash "${HOME}"/.unix_setup/config_files/git_setup.sh

if "$want_gui"; then
  sudo apt-get install -y keepassxc
  sudo apt-get install -y chromium-browser
  sudo apt-get install -y alacarte
  sudo apt-get install -y okular
  sudo apt-get install -y terminator
  sudo apt-get install -y gimp

fi

if "$want_flatpak"; then
  sudo apt-get install -y flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  # GNOME
  # sudo apt install gnome-software-plugin-flatpak
  # Install Gear Lever to manage AppImages
  flatpak install flathub it.mijorus.gearlever -y
fi

if "$want_kde"; then
  sudo apt-get install -y kde-config-flatpak
  sudo apt-get install -y yakuake
fi

if "$want_development"; then
  sudo apt-get install -y podman
  # Manual steps
  # install Docker
  true
fi

if "$want_ai"; then
  # Placeholder for AI tools
  sudo apt-get install -y npm
  npm i -g @openai/codex
fi

if "$want_omz"; then
  # Install omz autosuggestions
  # https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if "$want_custom_repo"; then
  # VS Codium
  # https://vscodium.com/
  wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
  echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
    | sudo tee /etc/apt/sources.list.d/vscodium.sources
  sudo apt-get update
  sudo apt-get install -y codium

  # Brave
  # https://brave.com/linux/
  sudo apt-get install -y curl
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
  sudo apt-get update
  sudo apt-get install -y brave-browser

  # Eza
  # https://github.com/eza-community/eza/blob/main/INSTALL.md
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update
  sudo apt-get install -y eza
fi


# Manual Steps
# Setup sudo for second user
# Setup ufw
# Change ssh port
# Set strong passwords
# Update .bashrc to include /usr/sbin/
# PATH=$PATH:/usr/sbin/

# Disable IPv6

# Install pyenv
# https://github.com/pyenv/pyenv
