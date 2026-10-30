
# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

eval "$($BREW_HOME/bin/brew shellenv)"

# path_helper (/etc/zprofile) pushes this behind the system paths; put it back in front
path=("$HOME/.local/bin" $path)
