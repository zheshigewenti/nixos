#!/usr/bin/env bash

# 1. 检查是否有 git，没有就开启临时 shell
if ! command -v git &> /dev/null; then
    echo "未检测到 git，正在开启临时环境..."
    nix-shell -p git --run "$0"  # 递归调用自己
    exit
fi

# 2. 既然现在有 git 了，开始克隆
REPO="https://github.com/zheshigewenti/nixos.git"
DEST="$HOME/nixos-config"

if [ ! -d "$DEST" ]; then
    git clone "$REPO" "$DEST"
fi

cd "$DEST"

# 3. 询问是否需要生成新的硬件配置（重装必备）
read -p "是否需要重新生成硬件配置？(y/n) " gen_hw
if [ "$gen_hw" == "y" ]; then
    sudo nixos-generate-config --show-hardware-config > ./nixos/hardware-configuration.nix
fi

# 4. 一键起飞
sudo nixos-rebuild switch --flake .#nixos
