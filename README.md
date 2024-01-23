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

- iTerm2

  Colors from the [catppuccin](https://github.com/catppuccin/iterm) by git submodule

- Starship

  Prerequisite [Fira Code Nerd Font](https://www.nerdfonts.com/font-downloads)

  ```shell
  brew install starship
  ```

- Git

- Vim

  `PlugInstall`

- [neovim](https://neovim.io/)

  `PlugInstall`

- kitty

  Prerequisite [NerdFontsSymbolsOnly.zip](https://github.com/ryanoasis/nerd-fonts/releases)

- [pnpm](https://pnpm.io/installation)

  `curl -fsSL https://get.pnpm.io/install.sh | sh -`

- Raycast

  The exported addons are in folder `raycast`

- [Bob](https://github.com/ripperhe/Bob/releases)

  The exported addons are in folder `Bob`

- [fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#using-homebrew)

## Frequently used third-party applications

- [Stats](https://github.com/exelban/stats)
- [Itsyctl](https://www.mowglii.com/itsycal/)
- [Snipaste](https://www.snipaste.com/)
- [Typora](https://typora.io/)
- [Input Source Pro](https://inputsource.pro/zh-CN)
- [Onefetch](https://github.com/o2sh/onefetch)
- [ripgrep](https://github.com/BurntSushi/ripgrep)

## Troubleshooting

- `~/.gitconfig` user name and email may be wrong
