#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--preset server|vm|vm_ai|desktop] [--gui] [--flatpak] [--development] [--kde] [--ai] [--omz] [--custom_repo] [--pyenv]"
  echo ""
  echo "Presets (individual flags can be added on top of any preset):"
  echo "  --preset server   Base packages only"
  echo "  --preset vm       Base + omz + pyenv"
  echo "  --preset vm_ai    Base + omz + ai"
  echo "  --preset desktop  Base + gui + flatpak + kde + custom_repo + omz"
}

want_gui=false
want_flatpak=false
want_development=false
want_kde=false
want_ai=false
want_omz=false
want_custom_repo=false
want_pyenv=false

for arg in "$@"; do
  case "$arg" in
    --preset)
      echo "Error: --preset requires a value (server, vm, vm_ai, or desktop)"
      usage
      exit 1
      ;;
    --preset=server)
      # Base packages only; nothing extra to set
      ;;
    --preset=vm)
      want_omz=true
      want_pyenv=true
      ;;
    --preset=vm_ai)
      want_omz=true
      want_ai=true
      ;;
    --preset=desktop)
      want_gui=true
      want_flatpak=true
      want_kde=true
      want_custom_repo=true
      want_omz=true
      ;;
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
    --pyenv)
      want_pyenv=true
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

# Determine the target user (works whether called directly or via sudo)
TARGET_USER="${SUDO_USER:-$USER}"

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
# sudo apt-get install -y gcc
sudo apt-get install -y net-tools
sudo apt-get install -y ufw
sudo apt-get install -y zsh
sudo apt-get install -y bat
sudo apt-get install -y eza
# sudo apt-get install -y wireguard
# sudo apt-get install -y wireguard-tools
sudo apt-get install -y traceroute
sudo apt-get install -y iftop
sudo apt-get install -y dnsutils
sudo apt-get install -y tcpdump
# sudo apt-get install -y fontconfig

# Change default shell to zsh for the target user
zsh_path="$(command -v zsh)"
sudo chsh -s "$zsh_path" "$TARGET_USER"

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
  # GNOME: sudo apt install gnome-software-plugin-flatpak
  # Install Gear Lever to manage AppImages
  flatpak install flathub it.mijorus.gearlever -y
fi

if "$want_kde"; then
  sudo apt-get install -y kde-config-flatpak
  sudo apt-get install -y yakuake
fi

if "$want_development"; then
  sudo apt-get install -y podman
  # Manual step: install Docker
  # https://docs.docker.com/engine/install/debian/
fi

if "$want_ai"; then
  echo "Installing Claude Code ..."
  curl -fsSL https://claude.ai/install.sh | bash
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.unix_setup/public/zshrc
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
  echo "Claude Code installed successfully!"
fi

if "$want_omz"; then
  # RUNZSH=no  — don't launch zsh after install (we're in a non-interactive script)
  # CHSH=no    — don't change the shell here; debian_install.sh already handles it
  # KEEP_ZSHRC=yes — don't prompt about backing up an existing .zshrc
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if "$want_custom_repo"; then
  # VS Codium — https://vscodium.com/
  wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
  echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
    | sudo tee /etc/apt/sources.list.d/vscodium.sources
  sudo apt-get update
  sudo apt-get install -y codium

  # Brave — https://brave.com/linux/
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
  sudo apt-get update
  sudo apt-get install -y brave-browser
fi

if "$want_pyenv"; then
  # pyenv — https://github.com/pyenv/pyenv
  curl -fsSL https://pyenv.run | bash
fi

# TODO: Nerd Font installation on Linux is not yet working reliably.
# On macOS, install via: brew install --cask font-jetbrains-mono-nerd-font
# On Linux, the steps needed are roughly:
#   1. Download JetBrainsMono.zip from https://www.nerdfonts.com/font-downloads
#   2. Extract *.ttf to /usr/local/share/fonts/JetBrainsMonoNerdFont/
#   3. Run fc-cache -fv
#   4. Configure the terminal emulator to use "JetBrainsMono Nerd Font Mono"
#      (for Terminator: Preferences > Profiles > General > Font)

# Manual steps:
# - Setup sudo for additional users
# - Configure ufw rules
# - Change SSH port in /etc/ssh/sshd_config
# - Set strong passwords
# - Add /usr/sbin to PATH in ~/.zshrc: export PATH=$PATH:/usr/sbin
# - Disable IPv6 (add to /etc/sysctl.conf):
#     net.ipv6.conf.all.disable_ipv6 = 1
#     net.ipv6.conf.default.disable_ipv6 = 1
