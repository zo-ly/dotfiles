# My settings

My application settings in sync (OS X) by [Mackup](https://github.com/lra/mackup)

## Restore

```bash
brew install mackup
```

```bash
git clone git@github.com:zo-ly/mackup_cfg.git ~/mackup_cfg
```

```bash
cp ~/mackup_cfg/.mackup.cfg ~/.mackup.cfg
```

```
mackup restore
```

## Back up

`cd ~/mackup_cfg` and sync to the origin repo by `Git` when backed up

```bash
mackup backup
```

## Backed up applications

- iTerm2

  Colors from the [catppuccin](https://github.com/catppuccin/iterm) by git submodule

- Zsh

- Starship

  Prerequisite [Fira Code Nerd Font](https://www.nerdfonts.com/font-downloads)

  ```bash
  brew install starship
  ```

- Git

- Vim

- neovim

  Prerequisite [vim-plug](https://github.com/junegunn/vim-plug)

  ```bash
  PlugInstall # in the neovim editor
  ```

- Raycast

- kitty

## Frequently used third-party applications

- [Stats](https://github.com/exelban/stats)
- [Itsyctl](https://www.mowglii.com/itsycal/)
- [Snipaste](https://www.snipaste.com/)
- [Bob](https://github.com/ripperhe/Bob/releases)
- [Typora](https://typora.io/)
- [Input Source Pro](https://inputsource.pro/zh-CN)
- [Onefetch](https://github.com/o2sh/onefetch)

## Troubleshooting

- `~/.zshrc` user's name may be wrong

- `~/.gitconfig` user name and email may be wrong
