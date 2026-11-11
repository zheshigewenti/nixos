每台新机器装之前，把 `hosts/desktop.nix` 里的 `my.disk.device` 改成目标磁盘（`lsblk` 确认；U 盘可能是 `/dev/sda`，内置盘可能是 `/dev/sdb`）。
```shell
passwd root
systemctl start sshd
ip a
cd /home/vincent/nixos
nix run github:nix-community/nixos-anywhere -- \
  --build-on local \
  --generate-hardware-config nixos-facter hosts/desktop-facter.json \
  --flake "path:$PWD#desktop" \
  root@<IP>
```
- `--build-on local` 在 xps 上构建（能用本地代理），之后整个闭包推到目标机。
- `--generate-hardware-config nixos-facter` 让 nixos-anywhere **在目标机上自动生成硬件报告**，写到 `hosts/desktop-facter.json`，不用手动复制。
- `path:$PWD` 让 flake 看到本地未提交的改动。
- 会清空 `my.disk.device` 指向的整块磁盘。
- 初始密码 `1234`，第一次登录后执行 `passwd` 改掉。
- 装完 openssh 已启用，可以直接 `ssh vincent@<IP>`（需先在 `keys/desktop-authorized-keys.nix` 填入公钥）。
- 只支持 UEFI；Legacy BIOS 需要把 `modules/disko.nix` 改成 MBR，并把 `modules/boot.nix` 的 systemd-boot 换成 GRUB。
- `desktop.nix` 里还有 NVIDIA 配置，装到非 NVIDIA 机器时先删掉那一段。

#### facter
 重新生成
  ```shell
  nix run github:nix-community/nixos-facter > hosts/desktop-facter.json
  ```
- 硬件变化（换盘、换主板、换整台机器）后要重新生成；只改软件不用。
- xps 仍用 `nixos-generate-config` 生成的 `hosts/xps-hardware.nix`（含 `fileSystems`，因为不走 disko）。


```shell
cd /home/vincent/nixos
nix run nixpkgs#git -- clone https://github.com/zheshigewenti/nixos.git
sudo chown -R vincent:users /home/vincent/nixos
# 重新生成硬件配置（包含 fileSystems，xps 不走 disko）
sudo nixos-generate-config --show-hardware-config > hosts/xps-hardware.nix
# 更新flake
nix flake update
```


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

#### 回滚

```shell
# 列出系统 generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
# 只保留最后 2 个 generation
sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system
# 回滚到上一个 generation
sudo nixos-rebuild switch --rollback
```

#### 清理

```shell
# 删除旧 generation 并执行 GC
sudo nix-collect-garbage -d
# 对 store 做硬链接去重
sudo nix store optimise
# 清理日志
sudo journalctl --rotate
sudo journalctl --vacuum-time=7d
```

#### 目录

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
  desktop.nix         # 通用安装模板（disko + nixos-anywhere + facter）
  desktop-facter.json # desktop 的硬件报告（nixos-facter 生成）
keys/
  desktop-authorized-keys.nix
                      # desktop 的 SSH 公钥（装完即可远程登录）
```

