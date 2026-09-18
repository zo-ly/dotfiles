# Dotfiles — Claude Context

## Repository Structure

```
dotfiles/
├── Mackup/        # Config files managed by Mackup (actual file contents)
├── Bob/           # Bob (macOS translation/OCR app) config export
├── raycast/       # Raycast scripts/extensions
└── README.md
```

## Security

**This repo is public**, and it syncs shell and git config out of `~`. Anything written into
`Mackup/.zshenv`, `.zshrc`, `.zprofile` or `.gitconfig` is published the moment it is pushed.

- Never put credentials (API keys, tokens, passwords) in a tracked file. Keep them in the macOS
  keychain, or somewhere outside what Mackup syncs — its Zsh app covers exactly `.zshenv`,
  `.zprofile`, `.zshrc`, `.zlogin` and `.zlogout`.
- A new file that has to carry secrets needs `filter=git-crypt` in `.gitattributes` **before**
  its first commit. Only `Bob/config.bobconfig` is encrypted today.
- If a secret does land in a commit, **rotate the credential**. Rewriting history does not undo
  a public leak — forks, caches and crawlers keep it.
- Precedent: `Bob/config.bobconfig` was committed as a plaintext zip from 2024-01 to 2025-03.
  The keys were rotated and the file encrypted in 370d475 (2026-03-16).
- Secret scanners do not cover this repo's main risk: they match patterns in text and do not
  look inside archives, so an unencrypted `.bobconfig` or `.rayconfig` passes unnoticed. That is
  why there is no pre-commit scan here — git-crypt is the control that matters.

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
