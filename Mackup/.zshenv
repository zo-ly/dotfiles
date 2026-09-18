# locale
export LANG=en_US.UTF-8
export ZSH=$HOME/.oh-my-zsh

# homebrew: /opt/homebrew on Apple Silicon, /usr/local on Intel
[ -x /opt/homebrew/bin/brew ] && export BREW_HOME=/opt/homebrew || export BREW_HOME=/usr/local

# keep PATH free of duplicates accumulated by nested shells
typeset -U path PATH

# user-local binaries
path=("$HOME/.local/bin" $path)
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# react-native configuration (workspace/next-app)
# tools/ and tools/bin are gone; the CLI tools now live in cmdline-tools/latest/bin
export ANDROID_HOME=$HOME/Library/Android/sdk
for _dir in "$ANDROID_HOME/emulator" "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/cmdline-tools/latest/bin"; do
  [ -d "$_dir" ] && path+=("$_dir")
done
unset _dir

# rust cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
