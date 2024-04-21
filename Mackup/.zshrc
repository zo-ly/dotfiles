eval "$(starship init zsh)"
eval "$(rbenv init -)"

# Alias
alias be="cd ~/Project/goldendata/"
alias fe="cd ~/Project/goldendata-frontend/apps/system"
alias vi="nvim"
alias myip="ifconfig en0 | awk '\$1 == \"inet\" {print \$2}'"

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
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

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
