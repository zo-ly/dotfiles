# My settings

My application settings in sync (macOS) by [Mackup](https://github.com/lra/mackup)

> ⚠️ **This repo is public.** Never commit credentials — shell and git config are synced out of
> `~`, so an exported token would be published. See [Security](CLAUDE.md#security).

> Mackup uses **copy mode** (not symlinks). macOS Sonoma 14+ no longer supports symlinked preferences.
> `mackup backup` copies files into this repo; `mackup restore` copies them back to `~`.

## Restore on a new machine

### 1. Install Homebrew

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> Apple Silicon uses `/opt/homebrew`, Intel uses `/usr/local`. The `$BREW_HOME` variable in `.zshenv` handles this — update it if needed.

### 2. Install prerequisites

CLI tools are managed by [mise](https://mise.jdx.dev/), installed with its own script (not brew — on Intel, brew would compile it from source):

```shell
curl https://mise.run | sh
~/.local/bin/mise use -g uv pipx:mackup
brew install git-crypt
```

### 3. Clone and unlock this repo

Mackup now works in **copy mode**, so this repo does not need to live at `~/dotfiles`.

```shell
git clone git@github.com:zo-ly/dotfiles.git
cd dotfiles
```

Unlock encrypted files (key stored in OneDrive):

```shell
git-crypt unlock ~/OneDrive/dotfile.key
```

### 4. Restore configs via Mackup

```shell
cp ./Mackup/.mackup.cfg ~/
cp -r ./Mackup/.mackup ~/
~/.local/bin/mise exec -- mackup restore
```

On an **Intel Mac**, also pin the tools whose upstream no longer ships x86_64 macOS binaries
(see `Mackup/.config/mise/config.intel.toml`):

```shell
echo 'export MISE_ENV=intel' >> ~/.zshenv.local
```

### 5. Install fonts

Required before setting up the shell prompt and terminal:

- [Fira Code Nerd Font](https://www.nerdfonts.com/font-downloads) — for Starship prompt
- [NerdFontsSymbolsOnly](https://github.com/ryanoasis/nerd-fonts/releases) — for kitty

### 6. Install CLI tools

Open a new terminal first, then:

```shell
mise install                 # everything in ~/.config/mise/config.toml, as prebuilt binaries
brew install btop            # no macOS release binary upstream
brew install --cask kitty
```

### 7. Install oh-my-zsh and plugins

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 8. Install Neovim plugins

LazyVim manages plugins automatically. On first launch just open Neovim and wait for the installation to complete:

```shell
nvim
```

### 9. Set up Claude Code status line

Mackup restores the [ccstatusline](https://github.com/sirmalloc/ccstatusline) widget config (`~/.config/ccstatusline/settings.json`), but not the `statusLine` entry in `~/.claude/settings.json`. Run the TUI once and choose **Install to Claude Code**:

```shell
npx -y ccstatusline@latest
```

### 10. Manual imports

- **Raycast** — import extensions from the `raycast/` folder
- **Bob** — translation/OCR app (paid build); import `Bob/config.bobconfig` from inside the app

---

## Back up

```shell
mackup backup
```

Then commit and push the changes in this repo.

---

## Day to day

```shell
mise use -g <tool>  # CLI tool with a macOS release binary; else brew install <tool>
brew install --cask <app>

mise upgrade        # upgrades and removes the replaced versions
brew upgrade        # on Intel, check `brew upgrade -n` first: anything without a bottle builds from source
mise self-update
mise prune -y       # occasionally: versions no config references any more
```

After `mise use -g`, run `mackup backup` and commit; on the other machine `git pull && mackup restore && mise install`.

## Migrating an existing machine from brew to mise

```shell
cd ~/dotfiles && git pull
curl https://mise.run | sh
mackup restore                                   # still the brew one at this point
echo 'export MISE_ENV=intel' >> ~/.zshenv.local   # Intel only
```

Check `~/.config/mise/config.toml` for a token or machine-only tools **before** `mackup restore` —
it is overwritten. Then, in a new terminal:

```shell
mise install
for f in starship neovim zoxide fzf ripgrep fd git-delta gh glab lazygit lazydocker onefetch mackup mise eza tailspin; do
  brew list "$f" &>/dev/null && brew uninstall "$f"
done
brew autoremove && brew cleanup -s
```

---

## Commonly used third-party applications

### CLI

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [Onefetch](https://github.com/o2sh/onefetch)
- [lazydocker](https://github.com/jesseduffield/lazydocker)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [delta](https://github.com/dandavison/delta) — git diff pager (already wired up in `~/.gitconfig`)
- [mise](https://mise.jdx.dev/getting-started.html) — language runtimes (Ruby / Node.js / pnpm) and CLI tools

### GUI

- [OrbStack](https://orbstack.dev/)
- [MonitorControl](https://github.com/MonitorControl/MonitorControl)
- [Stats](https://github.com/exelban/stats)
- [Ice](https://github.com/jordanbaird/Ice) — menu bar manager
- [Snipaste](https://www.snipaste.com/)
- [Typora](https://typora.io/)
- [Command X](https://sindresorhus.com/command-x)
- [Day Progress](https://sindresorhus.com/day-progress)
- [Calendr](https://github.com/pakerwreah/Calendr) — date format: `MMMdd日 E HH:mm` ([reference](https://www.mowglii.com/itsycal/datetime.html))
- [Latest](https://max.codes/latest/)
- [noTunes](https://github.com/tombonez/noTunes)
