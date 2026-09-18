
# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

eval "$($BREW_HOME/bin/brew shellenv)"

# path_helper (/etc/zprofile) pushes these behind the system paths; put them back in front
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)
