~/nixos/
├── flake.nix              # 根入口：声明 inputs (nixpkgs, nixvim) 与 outputs (nixosConfigurations)
├── flake.lock             # 依赖版本锁定文件
├── hosts/                 # 主机物理隔离层（单文件声明）
│   ├── xps.nix            # XPS 专属硬件与个性化配置
│   ├── surface.nix        # Surface 专属硬件与个性化配置
│   └── desktop.nix        # Desktop 专属硬件与个性化配置
└── modules/               # 共享与功能模块层
    ├── common.nix         # 基础公共配置（汇聚基础包、用户等）
    ├── nixvim.nix         # Nixvim 文本编辑器独立模块
    ├── nvidia.nix         # NVIDIA 显卡驱动模块
    └── zsh.nix            # Zsh 环境配置模块:
```shell
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
