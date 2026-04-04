eval "$(starship init zsh)"
eval "$(mise activate zsh)"

# Alias
alias vi="nvim"
alias ssh="kitten ssh"
alias cx="codex"
alias cc="claude"
alias myip="ifconfig en0 | awk '\$1 == \"inet\" {print \$2}'"
alias cfonts="system_profiler SPFontsDataType >> fonts.txt"

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

# Zoxide (--cmd z, hook triggers onefetch on directory change)
eval "$(zoxide init zsh --hook pwd)"
function __zoxide_cd_hook() {
	check_directory_for_new_repository
}
chpwd_functions+=(__zoxide_cd_hook)

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
## bindkey '^I' autosuggest-accept  # tab

# Claude Code: restore kitty keyboard protocol after exit
claude() {
    command claude "$@"
    printf '\e[<100u' >/dev/tty
}
