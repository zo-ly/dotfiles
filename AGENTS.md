# Dotfiles — Agent Context

## Repository Structure

```
dotfiles/
├── Mackup/        # Config files managed by Mackup (actual file contents)
├── Bob/           # Bob (macOS translation/OCR app) config export
├── raycast/       # Raycast scripts/extensions
├── windows/       # Windows-side scripts, installed by hand (not Mackup)
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
wezterm
zed
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
- **brew** — casks (GUI apps, kitty) and the few CLI tools with no macOS binary: `git`, `git-crypt`.
  `git` is not in mise's registry, and Apple's `/usr/bin/git` lags (2.50 vs 2.56), so it stays here
  and builds from source on Intel. Its build needs `cmake` and `pkgconf`, also built from source —
  expect a long first build and a few minutes per upgrade after that.

Intel caveat: some upstreams ship only arm64 for macOS (`delta` since 0.19, `onefetch` since 2.21).
`Mackup/.config/mise/config.intel.toml` pins the last x86_64 release, loaded via `MISE_ENV=intel`
in that machine's `~/.zshenv.local`. Before adding a tool, check its release assets if the Intel
Mac needs it too. Never run `mise upgrade --bump` there: it rewrites those pins to arm64-only versions.

`ruby` is pinned to a minor (`4.0`), not `latest`: mise's precompiled rubies (`jdx/ruby`) are
arm64-only, so on Intel every new version compiles from source and links brew's `libyaml` and
`openssl@4` (both kept as installed-on-request for that reason).

WSL (Windows): no brew. `apt` covers the system packages (`zsh`, `git`, `build-essential`), mise the
rest — Linux x86_64 binaries exist for every tool in `config.toml`. `MISE_ENV` stays unset there, and
`.zprofile` skips `brew shellenv` when `$BREW_HOME/bin/brew` is missing. A tool added for the Mac must
also ship a Linux release binary if Windows needs it.

Never put `[env]` secrets (e.g. `MISE_GITHUB_TOKEN`) in the mise config — it is synced and public.
Export them from `~/.zshenv.local` instead.

## Zsh aliases

`Mackup/.zshrc` loads oh-my-zsh's `git` plugin, which already defines ~200 git aliases (`gsh`,
`gco`, `gpr`, …) in `~/.oh-my-zsh/plugins/git/git.plugin.zsh`. Check there before adding one.

## kitty

Installed as a brew cask (`brew install --cask kitty`), so a plain `brew upgrade` covers it.

- `font_family` is deliberately unset: the default `monospace` resolves to Menlo, which ships with
  every macOS, and kitty's bundled `Symbols Nerd Font Mono` supplies the icons. Menlo has only
  Regular and Bold — a weight in between needs a different font.
- If `font_family` is set again, it must name a family kitty accepts as monospace — `FiraCode Nerd
  Font Mono`, not `FiraCode Nerd Font`. The non-Mono family is rejected and kitty falls back to Menlo
  without any visible error, after which changing `style=` does nothing. `kitty +list-fonts` shows
  what it accepts.
- `macos_thicken_font` is not used: kitty marks it obsolete in favour of `text_composition_strategy`.
  That one is left at its default too (`1.7 30` on macOS).
- Unknown options are ignored just as quietly. `padding_fill_strategy` and
  `restore_session_after_logout` are unknown to 0.48.2 and work on 0.50.0, so keep kitty current
  on every machine that restores this config.
- kitty watches `kitty.conf` and reloads on change; `mackup restore kitty` is enough to apply an edit.
- Mackup syncs `kitty.conf` only. It ends with `include current-theme.conf`, which is **not** in
  this repo — on a new machine create it with `kitten themes`.

## WezTerm (Windows)

Windows only — the Mac keeps kitty, and `wezterm.lua` has no macOS branches. Setup steps are in
README → Windows. The shell runs in WSL2; WezTerm is the native Windows app in front of it.

- Config: `Mackup/.config/wezterm/wezterm.lua`, synced by Mackup's built-in `wezterm` app into WSL's
  `~/.config/wezterm/`. Windows-side WezTerm reads it through the user env var `WEZTERM_CONFIG_FILE`
  = `\\wsl.localhost\Ubuntu\home\<user>\.config\wezterm\wezterm.lua`. Changes over that path may not
  trigger auto-reload; `Ctrl+Shift+R` reloads.
- `default_domain = 'WSL:Ubuntu'` must match `wsl -l -v`.
- Keys are a Windows scheme of their own, not a port of the Mac's: `Ctrl+Shift+…` belongs to the
  terminal, plain `Ctrl+letter` / `Alt+letter` go to zsh and Neovim. WezTerm's defaults already follow
  that; `wezterm.lua` only adds splits (`Enter`, `-`), pane moves (`H/J/K/L`, replacing the defaults
  ClearScrollback on K and ShowDebugOverlay on L), swap (`S`) and close pane (`D` — not `X`, which is the
  default copy mode). Common actions avoid arrow keys; the default arrow bindings stay. Check
  https://wezterm.org/config/default-keys.html before taking a new `Ctrl+Shift` key.
- Links open on `Ctrl+click` only; WezTerm's default opens them on a plain click.
- Splits keep the directory because `.zshrc` emits OSC 7 when `$WSL_DISTRO_NAME` is set.
- Not ported from kitty: the `tall` layout and its bias/mirror actions, the nvim scrollback pager.

## Windows scripts

`windows/` holds PowerShell for the Windows side, outside Mackup. Usage is in README → Windows.

- Target Windows PowerShell 5.1 (what Task Scheduler's `powershell.exe` is), not pwsh 7.
- Keep `.ps1` files ASCII-only: 5.1 reads BOM-less files as ANSI, so any Chinese text turns to mojibake.
- `install.ps1` copies the script to `%LOCALAPPDATA%` and points the task there. A logon task cannot run
  from `\\wsl.localhost` — WSL is not up yet. So a change to the repo file takes effect only after `install.ps1` is re-run.
- `unsplash-daily`: sets the desktop (`SystemParametersInfo`) and the lock screen
  (WinRT `LockScreen.SetImageFileAsync` — per user, no admin, but not loadable from pwsh 7). The key lives in
  the user env var `UNSPLASH_ACCESS_KEY`; `topic:` entries read a curated Unsplash topic; `wh:` entries go to Wallhaven,
  keyless and therefore SFW only. Unsplash downloads need `cs=srgb` — without it, Adobe RGB originals
  look washed out as a wallpaper.
  The folder and task keep the "Unsplash" name from before Wallhaven was added. The desktop right-click entries live under
  `HKCU\Software\Classes\DesktopBackground\Shell`; Windows 11 shows such legacy verbs only under
  *Show more options*, and their labels stay ASCII (see above). "屏保" here means the `Win+L` lock screen, not a classic screensaver.

## Bob

`Bob/config.bobconfig` is a config export from [Bob](https://bobtranslate.com/), the macOS translation / OCR app — **not** the Neovim version manager of the same name.

- Paid, closed-source build. The export is created and imported by hand from within the app; no automation needed here.
- Contains preferences plus installed plugins (openai-translator, a self-written aidict).
- The file is a zip — do not try to edit or diff it as text.

## Editor Setup

- **Primary editor**: Neovim via [LazyVim](https://www.lazyvim.org/) — config in `Mackup/.config/nvim/`
- **VSCode**: Uses vim extension (VSCodeVim), reads `~/.vimrc` for keymaps/settings
- **Zed**: Mackup's built-in `zed` app syncs only `~/.config/zed/settings.json` and `keymap.json` —
  themes, prompts and extensions are not in this repo
- **vim-plug is NOT used** — removed because VSCodeVim doesn't support it and Neovim uses LazyVim

`Mackup/.vimrc` contains only basic settings and keymaps compatible with VSCodeVim.
