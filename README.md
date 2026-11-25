# My settings

My application settings in sync (macOS, plus Windows via WSL2 — see [Windows](#windows-wsl2--wezterm)) by [Mackup](https://github.com/lra/mackup)

> ⚠️ **This repo is public.** Never commit credentials — shell and git config are synced out of
> `~`, so an exported token would be published. See [Security](AGENTS.md#security).

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

- [Fira Code Nerd Font](https://www.nerdfonts.com/font-downloads) — for Starship prompt and kitty (kitty uses the `Mono` family)
- [NerdFontsSymbolsOnly](https://github.com/ryanoasis/nerd-fonts/releases) — for kitty

### 6. Install CLI tools

Open a new terminal first, then:

```shell
mise install                 # everything in ~/.config/mise/config.toml, as prebuilt binaries
brew install git             # not in mise's registry; builds from source on Intel
```

kitty, as a brew cask (a prebuilt app, so it is fast on Intel too):

```shell
brew install --cask kitty
kitten themes                # creates ~/.config/kitty/current-theme.conf, which kitty.conf includes
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

## Windows (WSL2 + WezTerm)

The shell, Neovim and every mise tool run inside WSL2 (Ubuntu), so the same configs apply.
The terminal is [WezTerm](https://wezterm.org/install/windows.html), a native Windows app that opens
straight into WSL. No brew here: apt for the few system packages, mise for the rest.

### 1. WSL2 — admin PowerShell

```powershell
wsl --install            # WSL2 + Ubuntu; reboot, then create the Linux user when prompted
wsl -l -v                # the distro name; wezterm.lua assumes "Ubuntu"
```

WSL2 runs in a VM, so CPU virtualization must be on in the BIOS (Intel: *Intel Virtualization
Technology* / VT-x). If it is off, the install fails with `HCS_E_HYPERV_NOT_INSTALLED` even though
the *Virtual Machine Platform* feature is enabled. Check with
`(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` — it should be `True` after the reboot.

A forgotten Linux password needs no reinstall: `wsl -u root passwd <user>`.

### Proxy — if Windows reaches GitHub only through a local proxy

WSL2 ignores the Windows proxy by default. With Windows 11 22H2+ (build ≥ 22621), mirrored networking
lets WSL share the host's network and inherit its system proxy. Put this in `%USERPROFILE%\.wslconfig`,
then `wsl --shutdown`:

```ini
[wsl2]
networkingMode=mirrored
autoProxy=true
```

The proxy app must have *system proxy* on. Inside WSL, `env | grep -i _proxy` should now list it.
`sudo` drops those variables, so apt needs its own entry (use the proxy's port):

```shell
echo 'Acquire::http::Proxy "http://127.0.0.1:7890"; Acquire::https::Proxy "http://127.0.0.1:7890";' | sudo tee /etc/apt/apt.conf.d/95proxy
```

### 2. WezTerm

Install the nightly build: `WezTerm-nightly-setup.exe` from the
[nightly release](https://github.com/wezterm/wezterm/releases/tag/nightly) (the last stable release is from 2024).
Until step 4 it opens PowerShell — run `wsl` there, or use the Ubuntu app.

### 3. Shell and configs — inside WSL

oh-my-zsh must go in **before** `mackup restore`, or its installer overwrites `.zshrc`:

```shell
sudo apt update && sudo apt install -y zsh git curl build-essential unzip
chsh -s "$(which zsh)"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

curl https://mise.run | sh
~/.local/bin/mise use -g uv pipx:mackup

git clone https://github.com/zo-ly/dotfiles.git ~/dotfiles   # https: no ssh key yet
cp ~/dotfiles/Mackup/.mackup.cfg ~/
cp -r ~/dotfiles/Mackup/.mackup ~/
~/.local/bin/mise exec -- mackup restore

~/.local/bin/mise install
exec zsh
```

- Do **not** set `MISE_ENV=intel` here — those pins are for the Intel Mac only.
- If `mise install` starts compiling Ruby, add its build deps and rerun:
  `sudo apt install -y libssl-dev libyaml-dev zlib1g-dev libffi-dev libreadline-dev`
- `Bob/config.bobconfig` stays encrypted; nothing on Windows needs it, so no `git-crypt unlock`.

### 4. Point WezTerm at the synced config — PowerShell

The config lives in WSL (`~/.config/wezterm/wezterm.lua`, restored by Mackup). Tell Windows-side WezTerm where it is,
replacing `<user>` with the Linux user name:

```powershell
setx WEZTERM_CONFIG_FILE "\\wsl.localhost\Ubuntu\home\<user>\.config\wezterm\wezterm.lua"
```

Restart WezTerm: it should open in zsh with the starship prompt. Edits over this path may not reload
automatically — press `Ctrl+Shift+R`.

### Keys

Anything with `Ctrl+Shift` belongs to the terminal; plain `Ctrl+letter` / `Alt+letter` go to zsh and Neovim
(`Ctrl+A/E/U/W/R/K/L`, `Alt+F/B/.` all work). ★ = added in `wezterm.lua`, the rest are WezTerm defaults.

| Action | Keys |
|---|---|
| New tab / close tab | `Ctrl+Shift+T` / `Ctrl+Shift+W` |
| Next / previous tab | `Ctrl+Tab` / `Ctrl+Shift+Tab` |
| Go to tab N | `Ctrl+Shift+1..9` |
| ★ Split right / down (same directory) | `Ctrl+Shift+Enter` / `Ctrl+Shift+-` |
| ★ Move to pane left/down/up/right | `Ctrl+Shift+H/J/K/L` |
| ★ Swap pane with a picked one | `Ctrl+Shift+S` |
| Zoom pane | `Ctrl+Shift+Z` |
| ★ Close pane | `Ctrl+Shift+D` |
| Copy / paste | `Ctrl+Shift+C` / `Ctrl+Shift+V` |
| Search scrollback / copy mode | `Ctrl+Shift+F` / `Ctrl+Shift+X` |
| ★ Open link | `Ctrl+click` (a plain click only selects) |
| Reload config | `Ctrl+Shift+R` |

### Changing the config

Edit `~/.config/wezterm/wezterm.lua` in WSL, then `mackup backup` and commit from `~/dotfiles`
(pushing needs an ssh key or `gh auth login` in WSL).

### Unsplash wallpaper and lock screen — PowerShell

`windows/unsplash-daily/` sets a new photo each day on the desktop and a different one on the
lock screen (`Win+L`), by default from an Unsplash collection, cycling through all of its photos before
repeating one. Unsplash searches and topics, and Wallhaven (SFW, no key needed), also work as sources.
Get an Access Key at [unsplash.com/developers](https://unsplash.com/developers) (New Application), then:

```powershell
powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\zoly\dotfiles\windows\unsplash-daily\install.ps1 -RunNow
```

It asks for the key once (stored as the user variable `UNSPLASH_ACCESS_KEY`, never in the repo), copies the
script to `%LOCALAPPDATA%\UnsplashDaily` and registers the task *Unsplash Daily* (08:00 and at logon, once per day).

Settings → Personalization → *Background* and *Lock screen* must both be set to **Picture** — under
*Windows Spotlight* the lock screen keeps showing Spotlight's image.

- The `param()` defaults at the top of `unsplash-daily.ps1` hold the entries (`$Queries`, two drawn each
  day: `collection:<id>`, `topic:<slug>` for a curated Unsplash topic, `wh:<term>` for Wallhaven, or a plain
  Unsplash search term), the minimum width and the earliest upload year for searches and topics (`$Since`).
  Edit them in WSL, then run `install.ps1` again — the task uses the installed copy, not the repo file.
- New photos today: `powershell -ExecutionPolicy Bypass -File $env:LOCALAPPDATA\UnsplashDaily\unsplash-daily.ps1 -Force`.
  Each run uses 4–6 of the 50 Unsplash API requests allowed per hour.
- Desktop right-click → *Show more options* (or Shift+right-click) → *Unsplash*: open today's wallpaper or
  lock screen photo on Unsplash (to like or collect it), or swap either one for a new photo.
- Credits and errors go to `%USERPROFILE%\Pictures\Unsplash\log.txt`.
- Remove with `uninstall.ps1` in the same folder.

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
- [delta](https://github.com/dandavison/delta) — git diff pager (already wired up in `~/.gitconfig`)
- [mise](https://mise.jdx.dev/getting-started.html) — language runtimes (Ruby / Node.js / pnpm) and CLI tools

### GUI

- [OrbStack](https://orbstack.dev/)
- [MonitorControl](https://github.com/MonitorControl/MonitorControl)
- [Stats](https://github.com/exelban/stats)
- [Pelmet](https://github.com/fif7y/pelmet) — menu bar manager for macOS 27+
- [Snipaste](https://www.snipaste.com/)
- [Typora](https://typora.io/)
- [Command X](https://sindresorhus.com/command-x)
- [Calendr](https://github.com/pakerwreah/Calendr) — date format: `MMMdd日 E HH:mm` ([reference](https://www.mowglii.com/itsycal/datetime.html))
- [noTunes](https://github.com/tombonez/noTunes)
