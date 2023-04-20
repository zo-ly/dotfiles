eval "$(starship init zsh)"
eval "$(rbenv init -)"

# keybindings
bindkey '^I' autosuggest-accept  # tab  | autosuggest

# alias
alias la="exa -la --icons"
alias be="cd ~/Project/goldendata/"
alias fe="cd ~/Project/goldendata-frontend/apps/system"
alias vi="nvim"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  git
  gitfast
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

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

