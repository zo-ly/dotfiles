# Dotfiles — Claude Context

## Repository Structure

```
dotfiles/
├── Mackup/        # Config files managed by Mackup (actual file contents)
├── Bob/           # Bob version manager related configs
├── raycast/       # Raycast scripts/extensions
└── README.md
```

## Mackup

This repo is the Mackup storage backend (`engine = file_system`, `path = dotfiles`).

**How it works (copy mode, NOT symlink mode):**
- `mackup backup` — copies config files from `~` into `Mackup/`
- `mackup restore` — copies files from `Mackup/` back to `~`
- Files in `~` are plain copies, not symlinks

Symlink mode is intentionally avoided — macOS Sonoma (14+) broke symlinked preferences.

Config at `~/.mackup.cfg` (also tracked in `Mackup/.mackup.cfg`):
```ini
[storage]
engine = file_system
path = dotfiles

[applications_to_sync]
Zsh
Starship
Git
Vim
neovim
kitty
mine
```

**New machine setup:**
```bash
git clone <repo> ~/dotfiles
cp ~/dotfiles/Mackup/.mackup.cfg ~/.mackup.cfg
mackup restore
```

## Editor Setup

- **Primary editor**: Neovim via [LazyVim](https://www.lazyvim.org/) — config in `Mackup/.config/nvim/`
- **VSCode**: Uses vim extension (VSCodeVim), reads `~/.vimrc` for keymaps/settings
- **vim-plug is NOT used** — removed because VSCodeVim doesn't support it and Neovim uses LazyVim

`Mackup/.vimrc` contains only basic settings and keymaps compatible with VSCodeVim.
