# locale
export PATH=$PATH:/usr/local/sbin
export PATH=/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh
export LANG=en_US.UTF-8

# homebrew
export BREW_HOME="/usr/local"

# fix NSCFConstantString initialize error
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# user-local binaries
export PATH="$HOME/.local/bin:$PATH"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# react-native configuration
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# rust cargo
. "$HOME/.cargo/env"

# proxy
export https_proxy=http://127.0.0.1:7897
export http_proxy=http://127.0.0.1:7897
export all_proxy=socks5://127.0.0.1:7897
