# My settings

My application settings in sync (OS X) by [Mackup](https://github.com/lra/mackup)

## Restore

```shell
brew install mackup
```

```shell
git clone git@github.com:zo-ly/dotfiles.git ~/dotfiles
```

```shell
cp ~/dotfiles/Mackup/.mackup.cfg ~/

cp -r ~/dotfiles/Mackup/.mackup ~/
```

```
mackup restore
```

## Back up

`cd ~/dotfiles` and sync to the origin repo by `Git` when backed up

```shell
mackup backup
```

## Backed up applications

- [oh my zsh](https://ohmyz.sh/)

- [Homebrew](https://brew.sh/)

  Apple Silicon and Intel have different configurations [`/usr/local` to `/opt/homebrew`](https://www.reddit.com/r/MacOS/comments/jw9guu/why_did_homebrew_move_from_usrlocalto_opthomebrew/), modify the `$BREW_HOME` variable in the `.zshenv` file.

- Starship

  Prerequisite [Fira Code Nerd Font](https://www.nerdfonts.com/font-downloads)

  ```shell
  brew install starship
  ```

- Git

- Vim

  `PlugInstall` to install vim plugins

- [neovim](https://github.com/neovim/neovim/blob/master/INSTALL.md#homebrew-on-macos-or-linux)

  Prerequisite [vim-plug](https://github.com/junegunn/vim-plug?tab=readme-ov-file#neovim)

  `PlugInstall` to install neovim plugins

- kitty

  Prerequisite [NerdFontsSymbolsOnly.zip](https://github.com/ryanoasis/nerd-fonts/releases)

- [autojump](https://github.com/wting/autojump?tab=readme-ov-file#os-x)

- [auto-suggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh)

- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh)

- [pnpm](https://pnpm.io/installation)

  `curl -fsSL https://get.pnpm.io/install.sh | sh -`

- Raycast

  The exported addons are in folder `raycast`

- [Bob](https://github.com/ripperhe/Bob/releases)

  The exported addons are in folder `Bob`

- [fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#using-homebrew)

- iTerm2

  Colors from the [catppuccin](https://github.com/catppuccin/iterm) by git submodule

## Commonly used third-party applications

- [Stats](https://github.com/exelban/stats)
- [Itsyctl](https://www.mowglii.com/itsycal/)
- [Snipaste](https://www.snipaste.com/)
- [Typora](https://typora.io/)
- [Input Source Pro](https://inputsource.pro/zh-CN)
- [Onefetch](https://github.com/o2sh/onefetch)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [OrbStack](https://orbstack.dev/)
- [Dozer](https://github.com/Mortennn/Dozer)
- [Command X](https://sindresorhus.com/command-x)
- [Day Progress](https://sindresorhus.com/day-progress)
