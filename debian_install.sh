#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--preset server|vm|desktop] [--gui] [--flatpak] [--development] [--kde] [--ai] [--omz] [--custom_repo] [--eza] [--pyenv] [--nerd-font]"
  echo ""
  echo "Presets (individual flags can be added on top of any preset):"
  echo "  --preset server   Base packages only"
  echo "  --preset vm       Base + omz + eza + pyenv + nerd-font"
  echo "  --preset desktop  Base + gui + flatpak + kde + custom_repo + omz + eza + nerd-font"
}

want_gui=false
want_flatpak=false
want_development=false
want_kde=false
want_ai=false
want_omz=false
want_custom_repo=false
want_eza=false
want_pyenv=false
want_nerd_font=false

for arg in "$@"; do
  case "$arg" in
    --preset)
      echo "Error: --preset requires a value (server, vm, or desktop)"
      usage
      exit 1
      ;;
    --preset=server)
      # Base packages only; nothing extra to set
      ;;
    --preset=vm)
      want_omz=true
      want_eza=true
      want_pyenv=true
      want_nerd_font=true
      ;;
    --preset=desktop)
      want_gui=true
      want_flatpak=true
      want_kde=true
      want_custom_repo=true
      want_omz=true
      want_eza=true
      want_nerd_font=true
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
    --eza)
      want_eza=true
      ;;
    --pyenv)
      want_pyenv=true
      ;;
    --nerd-font)
      want_nerd_font=true
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

sudo apt-get install -y \
  gnupg2 \
  curl \
  nmap \
  sudo \
  nano \
  vim \
  tmux \
  openvpn \
  git \
  unzip \
  htop \
  gcc \
  net-tools \
  ufw \
  zsh \
  bat \
  wireguard \
  wireguard-tools \
  # iperf3 \
  traceroute \
  iftop \
  dnsutils \
  tcpdump \
  fontconfig

# Change default shell to zsh for root and the target user
zsh_path="$(command -v zsh)"
sudo chsh -s "$zsh_path"
sudo chsh -s "$zsh_path" "$TARGET_USER"

# pyenv: not available via apt — install manually if needed
# See: https://github.com/pyenv/pyenv#installation

if "$want_gui"; then
  sudo apt-get install -y \
    keepassxc \
    chromium-browser \
    alacarte \
    okular \
    terminator \
    gimp
fi

if "$want_flatpak"; then
  sudo apt-get install -y flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  # GNOME: sudo apt install gnome-software-plugin-flatpak
  # Install Gear Lever to manage AppImages
  flatpak install flathub it.mijorus.gearlever -y
fi

if "$want_kde"; then
  sudo apt-get install -y \
    kde-config-flatpak \
    yakuake
fi

if "$want_development"; then
  sudo apt-get install -y podman
  # Manual step: install Docker
  # https://docs.docker.com/engine/install/debian/
fi

if "$want_ai"; then
  # Manual step: install Node.js, then npm i -g @openai/codex or @anthropic-ai/claude-code
  # https://nodejs.org/en/download
  true
fi

if "$want_omz"; then
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

if "$want_eza"; then
  # Eza — https://github.com/eza-community/eza/blob/main/INSTALL.md
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update
  sudo apt-get install -y eza
fi

if "$want_pyenv"; then
  # pyenv — https://github.com/pyenv/pyenv
  curl -fsSL https://pyenv.run | bash
fi

if "$want_nerd_font"; then
  # JetBrains Mono Nerd Font — required for eza --icons and terminal icon rendering
  # https://www.nerdfonts.com/
  FONT_DIR="/usr/local/share/fonts/JetBrainsMonoNerdFont"
  sudo mkdir -p "$FONT_DIR"
  wget -qO /tmp/JetBrainsMono.zip \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  sudo unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
  rm /tmp/JetBrainsMono.zip
  sudo fc-cache -fv
fi

# Manual steps:
# - Setup sudo for additional users
# - Configure ufw rules
# - Change SSH port in /etc/ssh/sshd_config
# - Set strong passwords
# - Add /usr/sbin to PATH in ~/.zshrc: export PATH=$PATH:/usr/sbin
# - Disable IPv6 (add to /etc/sysctl.conf):
#     net.ipv6.conf.all.disable_ipv6 = 1
#     net.ipv6.conf.default.disable_ipv6 = 1
