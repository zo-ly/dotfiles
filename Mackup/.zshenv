# locale
export PATH=$PATH:/usr/local/sbin
export PATH=/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh
export LANG=en_US.UTF-8

# homebrew
export BREW_HOME="/usr/local"

# fix NSCFConstantString initialize error
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# react-native configuration
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# rust cargo
. "$HOME/.cargo/env"

