# Dotfiles — Claude Context

## Repository Structure

```
dotfiles/
├── Mackup/        # Config files managed by Mackup (actual file contents)
├── Bob/           # Bob (macOS translation/OCR app) config export
├── raycast/       # Raycast scripts/extensions
└── README.md
```

## Mackup

This repo is the Mackup storage backend (`engine = file_system`, `path = dotfiles`).

**How it works (copy, NOT symlink):**
- `mackup backup` — copies config files from `~` into `Mackup/`
- `mackup restore` — copies files from `Mackup/` back to `~` (deletes the existing target first, then copies — directories are replaced whole, not merged; restored files get chmod 0600/0700)
- Files in `~` are plain copies, not symlinks

In Mackup 0.11+, backup/restore always copy — `engine` only sets the storage location, not the sync mode. Symlinking is a separate `mackup link install` command, intentionally never used here (macOS Sonoma 14+ broke symlinked preferences).

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

## Bob

`Bob/config.bobconfig` is a config export from [Bob](https://bobtranslate.com/), the macOS translation / OCR app — **not** the Neovim version manager of the same name.

- Paid, closed-source build. The export is created and imported by hand from within the app; no automation needed here.
- Contains preferences plus installed plugins (openai-translator, a self-written aidict).
- The file is a zip — do not try to edit or diff it as text.

## Editor Setup

- **Primary editor**: Neovim via [LazyVim](https://www.lazyvim.org/) — config in `Mackup/.config/nvim/`
- **VSCode**: Uses vim extension (VSCodeVim), reads `~/.vimrc` for keymaps/settings
- **vim-plug is NOT used** — removed because VSCodeVim doesn't support it and Neovim uses LazyVim

`Mackup/.vimrc` contains only basic settings and keymaps compatible with VSCodeVim.
