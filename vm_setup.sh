#!/bin/bash
set -euo pipefail

# Single-command VM setup: installs packages, configures shell, and links dotfiles.
# Run from the repo root, or from anywhere — the script resolves its own location.
#
# Usage: ./vm_setup.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [1/3] Installing packages (preset: vm)..."
# RUNZSH=no prevents the omz installer from opening an interactive zsh session.
# CHSH=no skips omz's own chsh — debian_install.sh already handles it.
export RUNZSH=no
export CHSH=no
"$SCRIPT_DIR/debian_install.sh" --preset=vm

echo "==> [2/3] Linking dotfiles..."
ln -sf "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"
ln -sf "$SCRIPT_DIR/robbyrussell.zsh-theme" "$HOME/.oh-my-zsh/themes/robbyrussell.zsh-theme"
if [[ -f "$SCRIPT_DIR/tmux.conf" ]]; then
  ln -sf "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"
fi

echo "==> [3/3] Updating system..."
# shellcheck source=scripts/general_update.sh
source "$SCRIPT_DIR/scripts/general_update.sh"
update_debian

echo ""
echo "Done. Log out and back in (or run: exec zsh) to start using zsh."
