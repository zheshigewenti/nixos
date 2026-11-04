# NixOS 配置

## 日常部署

```shell
cd /home/vincent/nixos

# 验证部署
sudo nixos-rebuild build --flake .#xps

# 实际部署
sudo nixos-rebuild switch --flake .#xps

# 代理部署
ALL_PROXY=socks5://127.0.0.1:7897 sudo -E nixos-rebuild switch --flake .#xps

# 远程部署
sudo nixos-rebuild switch --flake github:zheshigewenti/nixos#xps
```

## 更新

```shell
# 更新flake
nix flake update
```
## 硬件与引导

```shell
# 重新生成当前机器的硬件配置
sudo nixos-generate-config --show-hardware-config > hosts/xps-hardware.nix

# 重新安装 systemd-boot
sudo nixos-rebuild boot --install-bootloader
```

## 版本回滚

```shell
# 列出系统 generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# 只保留最后 2 个 generation
sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system

# 回滚到上一个 generation
sudo nixos-rebuild switch --rollback
```

## 清理

```shell
# 删除旧 generation 并执行 GC
sudo nix-collect-garbage -d

# 对 store 做硬链接去重
sudo nix store optimise

# 清理日志
sudo journalctl --rotate
sudo journalctl --vacuum-time=7d
```


## 临时下载仓库

```shell
nix run nixpkgs#git -- clone https://github.com/zheshigewenti/nixos.git

# 如果文件属主不对
sudo chown -R vincent:users /home/vincent/nixos
```

## 目录

```text
flake.nix
modules/
  init.nix            # 入口：聚合所有共享模块
  boot.nix            # 内核、systemd-boot、/tmp 清理
  nix.nix             # Nix 设置、GC、cache
  network.nix         # 网络、时区、locale
  gnome.nix           # GNOME、GDM、Flatpak
  graphics.nix        # 通用图形设置
  system.nix          # journald、zram、swappiness
  packages.nix        # 用户和软件包
  steam.nix           # Steam
  fonts.nix           # 字体
  fcitx5.nix          # fcitx5
  nixvim.nix          # Neovim
  tmux.nix            # tmux
  zsh.nix             # zsh
hosts/
  configurations.nix  # flake-parts host 定义
  xps.nix
  xps-hardware.nix
  desktop.nix
  desktop-hardware.nix
```

