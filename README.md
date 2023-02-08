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

**Warning** 需要使用除 `iTerm2` 以外的终端运行备份命令，否则同步 `iTerm2` 文件配置会冲突报错 [issue](https://github.com/lra/mackup/issues/1855)

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
- [Typora](https://typora.io/)
- [Input Source Pro](https://inputsource.pro/zh-CN)

## Troubleshooting

- `~/.zshrc` user's name may be wrong
