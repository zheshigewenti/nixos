```shell
sudo nixos-rebuild switch --flake github:zheshigewenti/nixos#nixos #云端部署
nix flake update #更新lock文件
sudo chown -R vincent nixos #将文件所有者递归改为vincent
sudo nixos-rebuild switch --flake .
sudo nixos-rebuild boot --install-bootloader #重新覆盖引导程序
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system #列出nixos当前保留了哪些版本
sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system #保留最后2个版本
sudo nix-collect-garbage #删除无用的版本
sudo nix-store --gc #清理所有不再被任何版本引用的包
sudo journalctl --rotate #将当前日志封存归档
sudo journalctl --vacuum-time=1s #清理1秒前的日志
```
