```shell
ALL_PROXY=socks5://127.0.0.1:7897 sudo -E nixos-rebuild switch --flake .#xps
nix flake update #更新lock文件
sudo nixos-rebuild switch --flake .#hostname
sudo nixos-rebuild switch --flake github:zheshigewenti/nixos#hostname #云端部署
nix run nixpkgs#git -- clone https://github.com/zheshigewenti/nixos.git
sudo nixos-generate-config --show-hardware-config > hostname.nix #硬件配置覆盖
sudo chown -R vincent nixos #将文件所有者递归改为vincent
sudo nixos-rebuild boot --install-bootloader #重新覆盖引导程序
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system #列出nixos当前保留了哪些版本
sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system #保留最后2个版本
sudo nix-collect-garbage #删除无用的版本
sudo nix-store --gc #清理所有不再被任何版本引用的包
sudo journalctl --rotate #将当前日志封存归档
sudo journalctl --vacuum-time=1s #清理1秒前的日志
```

---

# NixOS 配置

## 主机

- `xps`：当前机器
- `desktop`：新机器，首次使用前需要生成 `hosts/desktop-hardware.nix`

## 部署

```shell
# 先验证，不激活
sudo nixos-rebuild build --flake .#xps

# 应用
sudo -E nixos-rebuild switch --flake .#xps

# 需要代理时
ALL_PROXY=socks5://127.0.0.1:7897 sudo -E nixos-rebuild switch --flake .#xps
```

## 新机器 desktop

```shell
# 在 live 环境中生成硬件配置
ssh root@新机器IP 'nixos-generate-config --show-hardware-config' \
  > hosts/desktop-hardware.nix

# 验证
nixos-rebuild build --flake .#desktop

# 安装 / 部署
nixos-rebuild switch --flake .#desktop
```

或者使用 `nixos-anywhere` 自动生成硬件配置并安装：

```shell
nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config \
  "$PWD/hosts/desktop-hardware.nix" \
  --flake "$PWD#desktop" \
  --target-host root@新机器IP
```

## 更新

```shell
nix flake update
```

## 清理

```shell
sudo nix-collect-garbage -d
sudo nix store optimise
sudo journalctl --vacuum-time=7d
```

## 系统版本

```shell
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system
```

## 目录

```text
flake.nix
modules/
  common.nix          # 聚合 import
  boot.nix            # 内核、systemd-boot
  nix.nix             # Nix 设置、GC、cache
  network.nix         # 网络、时区、locale
  desktop.nix         # GNOME、GDM、Flatpak
  graphics.nix        # 通用图形设置
  system.nix          # journald、zram、stateVersion
  packages.nix        # 用户和软件包
  gaming.nix          # Steam
  fonts.nix           # 字体
  input-method.nix    # fcitx5
  nixvim.nix          # Neovim
  tmux.nix            # tmux
  zsh.nix             # zsh
  configurations.nix  # flake-parts host 定义
hosts/
  xps.nix
  xps-hardware.nix
  desktop.nix
  desktop-hardware.nix
```
