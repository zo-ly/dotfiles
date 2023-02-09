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

现在 Mackup 有 bug 需要退出 `iTerm2` ，使用其它终端运行备份命令，否则同步 `iTerm2` 文件设置时会报错 [issue](https://github.com/lra/mackup/issues/1855)，有 [PR](https://github.com/lra/mackup/pull/1864) 已经修复了这个问题，不知道作者什么时候合并

`cd ~/mackup_cfg` and sync to the origin repo by `Git` when backed up

```bash
mackup backup
```

## Backed up applications

- iTerm2

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

## Frequently used third-party applications

- [Stats](https://github.com/exelban/stats)
- [Itsyctl](https://www.mowglii.com/itsycal/)
- [Snipaste](https://www.snipaste.com/)
- [Bob](https://github.com/ripperhe/Bob/releases)
- [Typora](https://typora.io/)
- [Input Source Pro](https://inputsource.pro/zh-CN)

## Troubleshooting

- `~/.zshrc` user's name may be wrong

- `~/.gitconfig` user name and email may be wrong
