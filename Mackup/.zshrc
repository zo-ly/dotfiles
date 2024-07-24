eval "$(starship init zsh)"
eval "$(rbenv init -)"

# Alias
alias vi="nvim"
alias myip="ifconfig en0 | awk '\$1 == \"inet\" {print \$2}'"
alias py3="python3"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  git
  gitfast
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# AutoJump
[ -f $BREW_HOME/etc/profile.d/autojump.sh ] && . $BREW_HOME/etc/profile.d/autojump.sh

# Onefetch
last_repository=
check_directory_for_new_repository() {
	current_repository=$(git rev-parse --show-toplevel 2> /dev/null)

	if [ "$current_repository" ] && \
	   [ "$current_repository" != "$last_repository" ]; then
		onefetch
	fi
	last_repository=$current_repository
}
cd() {
	builtin cd "$@"
	check_directory_for_new_repository
}
check_directory_for_new_repository

# Check the weather
tq() {
  local location="${1:-chengdu}"
  curl "wttr.in/${location}"
}

# fzf
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# Keybindings
## autosuggest
bindkey '^I' autosuggest-accept  # tab

# pnpm
export PNPM_HOME="/Users/zoly/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
