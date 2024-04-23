# locale
export PATH=$PATH:/usr/local/sbin
export PATH=/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh
export LANG=en_US.UTF-8

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"

# homebrew
export BREW_HOME="/opt/homebrew"

# fix NSCFConstantString initialize error
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# react-native configuration
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# python
export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:${PATH}"

# pnpm
export PNPM_HOME="/Users/zoly/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# rust cargo
. "$HOME/.cargo/env"

