# mise first: starship, zoxide, fzf etc. are installed by mise
eval "$(mise activate zsh)"
eval "$(starship init zsh)"

# Alias
alias j="z"
alias vi="nvim"
alias cx="codex"
alias cc="claude"
alias myip="ipconfig getifaddr en0"
alias cfonts="system_profiler SPFontsDataType >> fonts.txt"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# Onefetch: show repo info when entering a new repository
# chpwd covers cd, z, pushd/popd; -t 1 skips non-tty shells (e.g. agent tool shells)
last_repository=
check_directory_for_new_repository() {
	[[ -t 1 ]] || return
	local current_repository=$(git rev-parse --show-toplevel 2> /dev/null)

	if [[ -n $current_repository && $current_repository != $last_repository ]]; then
		onefetch
	fi
	last_repository=$current_repository
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd check_directory_for_new_repository
check_directory_for_new_repository

# Zoxide
eval "$(zoxide init zsh --hook pwd)"

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

# kitty-only: ssh via kitten (ships terminfo), restore keyboard protocol after Claude Code exits
if [[ $TERM == xterm-kitty ]]; then
  alias ssh="kitten ssh"
  claude() {
    command claude "$@"
    printf '\e[<100u' >/dev/tty
  }
fi
