# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder    # just remind me to update when it's time

ENABLE_CORRECTION="true"

# On macOS, zsh-autosuggestions is loaded via brew below.
# On Linux, it is loaded as an oh-my-zsh plugin.
if [[ "$OSTYPE" == "darwin"* ]]; then
    plugins=(
        git
        web-search
        copyfile
    )
else
    plugins=(
        git
        zsh-autosuggestions
        web-search
        copyfile
    )
fi

ZSH_DISABLE_COMPFIX=false

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='mvim'
fi

# Aliases
alias src="source ~/.zshrc"
alias esrc="vim ~/.zshrc"
alias v="vim"
alias ls="eza --icons=always --git --git-repos"

source "${HOME}/.unix_setup/scripts/general_update.sh"

# If VS Code is not installed, invoke VS Codium with the same command
if ! command -v code >/dev/null 2>&1; then
    alias code='codium'
fi

# Functions
source "${HOME}/.unix_setup/functions/addssh.sh"
source "${HOME}/.unix_setup/functions/mkdiro.sh"
source "${HOME}/.unix_setup/functions/touch2.sh"

# Use thin cursor instead of block-shaped cursor
echo '\e[5 q'

# Avoid autocorrection
unsetopt correct_all

# Go
export GOPATH=$HOME/golang_code
export PATH=$HOME/golang_code/bin:$PATH

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# =============================================================================
# Platform-specific configuration
# =============================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then

    # Homebrew — source binaries before system binaries
    export PATH=/opt/homebrew/bin:$PATH

    # zsh-autosuggestions (via brew)
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

    # iTerm2 shell integration
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

    # Pyenv
    eval "$(pyenv init - zsh)"
    eval "$(pyenv virtualenv-init -)"


    # Java (Zulu OSS JDK for React Native Development)
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

    # Android Studio
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools

    # LM Studio CLI
    export PATH="$PATH:$HOME/.lmstudio/bin"

else
    # Linux

    # pbcopy / pbpaste via xsel
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'

    # bat
    alias bat="batcat"

    # Pyenv
    eval "$(pyenv init -)"

    # NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

fi
