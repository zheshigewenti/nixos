#!/usr/bin/env bash

# 1. 检查是否有 git，没有就开启临时 shell
if ! command -v git &> /dev/null; then
    echo "未检测到 git，正在开启临时环境..."
    nix-shell -p git --run "bash $0"
    exit
fi

# 2. 变量定义
REPO="https://github.com/zheshigewenti/nixos.git"
DEST="$HOME/nixos"

# 3. 克隆仓库
if [ ! -d "$DEST" ]; then
    echo "正在克隆配置仓库..."
    git clone "$REPO" "$DEST"
fi

# 进入配置目录
cd "$DEST"

# 4. 询问是否需要生成新的硬件配置
read -p "是否需要重新生成硬件配置？(y/n) " gen_hw
if [ "$gen_hw" == "y" ]; then
    echo "正在生成硬件配置..."
    sudo nixos-generate-config --show-hardware-config > ./hardware-configuration.nix
fi

# 5. 执行部署
echo "开始部署 NixOS 系统..."
sudo nixos-rebuild switch --flake .#nixos
