# Dotfiles — Agent Context

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
  keychain, or in `~/.zshenv.local` (see [Machine-local config](#machine-local-config)) — Mackup's
  Zsh app covers exactly `.zshenv`, `.zprofile`, `.zshrc`, `.zlogin` and `.zlogout`, nothing else.
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
- Both take an optional app name (`mackup restore kitty`) to limit the run to one app; `-n` is a dry run

The unit that gets replaced is each path in the app's definition, not its parent directory —
check with `mackup show <app>` before assuming what a restore touches. `kitty` covers only
`.config/kitty/kitty.conf`; `neovim` covers `init.lua`, `lua/` and a few sibling entries, so
`lazy-lock.json`, `lazyvim.json` and kitty's theme files are never synced nor deleted.

To pick up a change on an existing machine: `git pull`, then `mackup restore [<app>]`.

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

## Machine-local config

Anything that must not leave this machine — proxies, work-only PATH entries, credentials — goes in
`~/.zshenv.local`, sourced at the end of `Mackup/.zshenv`. Mackup's Zsh app syncs only the five
files listed under [Security](#security), so `.zshenv.local` is never copied into this repo and
never published. It is also the reason `Mackup/.zshenv` itself stays machine-agnostic: prefer a
runtime probe (as `BREW_HOME` does) over hardcoding, and push the rest here.

Because it is untracked, a new machine starts without it — recreate it by hand during setup.

## Tool management

Homebrew moved Intel macOS to Tier 3 in 7.0.0 (2026-09): no new bottles, so on the 2019 Intel Mac
every upgraded formula builds from source (rust/llvm toolchains took 10+ hours). Hence the split:

- **mise** — language runtimes and every CLI tool whose upstream ships a macOS release binary.
  The list lives in `Mackup/.config/mise/config.toml`, synced by the `mine` Mackup app.
  mise itself is installed via `curl https://mise.run | sh`, not brew.
- **brew** — casks (GUI apps, kitty) and the few CLI tools with no macOS binary: `btop`, `git-crypt`.

Intel caveat: some upstreams ship only arm64 for macOS (`delta` since 0.19, `onefetch` since 2.21).
`Mackup/.config/mise/config.intel.toml` pins the last x86_64 release, loaded via `MISE_ENV=intel`
in that machine's `~/.zshenv.local`. Before adding a tool, check its release assets if the Intel
Mac needs it too. Never run `mise upgrade --bump` there: it rewrites those pins to arm64-only versions.

`ruby` is pinned to a minor (`4.0`), not `latest`: mise's precompiled rubies (`jdx/ruby`) are
arm64-only, so on Intel every new version compiles from source and links brew's `libyaml` and
`openssl@4` (both kept as installed-on-request for that reason).

Never put `[env]` secrets (e.g. `MISE_GITHUB_TOKEN`) in the mise config — it is synced and public.
Export them from `~/.zshenv.local` instead.

## kitty

Installed as a brew cask (`brew install --cask kitty`), so a plain `brew upgrade` covers it.

- `font_family` must name a family kitty accepts as monospace — `FiraCode Nerd Font Mono`, not
  `FiraCode Nerd Font`. The non-Mono family is rejected and kitty falls back to Menlo without any
  visible error, after which changing `style=` does nothing. `kitty +list-fonts` shows what it accepts.
- Unknown options are ignored just as quietly. `padding_fill_strategy` and
  `restore_session_after_logout` are unknown to 0.48.2 and work on 0.50.0, so keep kitty current
  on every machine that restores this config.
- kitty watches `kitty.conf` and reloads on change; `mackup restore kitty` is enough to apply an edit.
- Mackup syncs `kitty.conf` only. It ends with `include current-theme.conf`, which is **not** in
  this repo — on a new machine create it with `kitten themes`.

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
