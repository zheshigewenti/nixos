## 安装

### desktop（通用模板，nixos-anywhere）

`hosts/desktop.nix` 就是通用模板，磁盘布局和 xps 一致：

- GPT 分区表
- `ESP`：1G，vfat，挂到 `/boot`
- `root`：剩余空间，ext4，挂到 `/`
- 不建 swap，使用 `zramSwap`

每台新机器装之前，把 `hosts/desktop.nix` 里的 `my.disk.device` 改成目标磁盘（`lsblk` 确认；U 盘可能是 `/dev/sda`，内置盘可能是 `/dev/sdb`）。

目标机启动 NixOS ISO、联网后：

```shell
passwd root
systemctl start sshd
ip a
```

在 xps 上：

```shell
nix run github:nix-community/nixos-anywhere -- \
  --flake "path:$PWD#desktop" \
  root@<IP>
```

- `path:$PWD` 让 flake 看到本地未提交的改动。
- 会清空 `my.disk.device` 指向的整块磁盘。
- 初始密码 `1234`，第一次登录后执行 `passwd` 改掉。
- 只支持 UEFI；Legacy BIOS 需要把 `modules/disko.nix` 改成 MBR，并把 `modules/boot.nix` 的 systemd-boot 换成 GRUB。
- `desktop.nix` 里还有 NVIDIA 配置，装到非 NVIDIA 机器时先删掉那一段。

### xps（沿用现有分区，UUID）

```shell
cd /home/vincent/nixos
nix run nixpkgs#git -- clone https://github.com/zheshigewenti/nixos.git
sudo chown -R vincent:users /home/vincent/nixos

# 重新生成硬件配置（包含 fileSystems，xps 不走 disko）
sudo nixos-generate-config --show-hardware-config > hosts/xps-hardware.nix

# 更新flake
nix flake update
```

### 已装好的系统更新

```shell
# 验证部署
sudo nixos-rebuild build --flake .#xps

# 实际部署
sudo nixos-rebuild switch --flake .#xps

# 代理部署
ALL_PROXY=socks5://127.0.0.1:7897 sudo -E nixos-rebuild switch --flake .#xps

# 远程部署
sudo nixos-rebuild switch --flake github:zheshigewenti/nixos#xps

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

## 目录

```text
flake.nix
modules/
  init.nix            # 入口：聚合所有共享模块
  disko.nix           # 磁盘布局：GPT + 1G ESP + ext4 root
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
  desktop.nix         # 通用安装模板（disko + nixos-anywhere）
  desktop-hardware.nix
```

