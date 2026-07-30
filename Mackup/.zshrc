eval "$(starship init zsh)"
eval "$(mise activate zsh)"

# Alias
alias j="z"
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

# Markdown preview: open a markdown file in nvim and auto-launch preview
mdp() {
  nvim "$1" -c "MarkdownPreview"
}

# Check the weather
tq() {
  local location="${1:-chengdu}"
  curl "wttr.in/${location}"
}

# fzf
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# git branch commands: with args, pass through to git; without, pick via fzf
# (local branches, recent commit first, current branch excluded)
__gbr_pick() {
  git branch --sort=-committerdate --format='%(refname:short)' 2>/dev/null \
    | grep -vx "$(git branch --show-current)" \
    | fzf --height 40% --reverse --border \
          --preview 'git log --oneline --graph --color=always -20 {}' "$@"
}
__gbr_delete() {
  local flag=$1; shift
  if (( $# )); then
    git branch "$flag" "$@"
    return
  fi
  local branches
  branches=$(__gbr_pick --multi) || return
  [[ -z $branches ]] && return
  git branch "$flag" ${(f)branches}
}

unalias gco gbd gbD 2>/dev/null
gco() {
  if (( $# )); then
    git checkout "$@"
    return
  fi
  local branch
  branch=$(__gbr_pick) || return
  [[ -z $branch ]] && return
  git switch "$branch"
}
gbd() { __gbr_delete -d "$@"; }
gbD() { __gbr_delete -D "$@"; }

# Keybindings
## autosuggest
bindkey '^[[Z' autosuggest-accept  # shift+tab

# Claude Code: restore kitty keyboard protocol after exit
claude() {
    command claude "$@"
    printf '\e[<100u' >/dev/tty
}
