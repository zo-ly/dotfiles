
# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

[ -x "$BREW_HOME/bin/brew" ] && eval "$($BREW_HOME/bin/brew shellenv)"  # no brew in WSL

# path_helper (/etc/zprofile) pushes this behind the system paths; put it back in front
path=("$HOME/.local/bin" $path)
