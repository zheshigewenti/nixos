```shell
curl -L https://raw.githubusercontent.com/zheshigewenti/nixos/master/install.sh -o install.sh
chmod +x install.sh
./install.sh

sudo chown -R vincent nixos #将文件所有者递归改为vincent
sudo nix flake update #更新lock文件
sudo nixos-rebuild switch --flake .
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system #列出nixos当前保留了哪些版本
sudo nix-env --delete-generations +2 --profile /nix/var/nix/profiles/system #保留最后2个版本
sudo nix-collect-garbage #删除无用的版本
sudo nix-store --gc #清理所有不再被任何版本引用的包
```
