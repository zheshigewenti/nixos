```shell
sudo chown -R vincent nixos
git config --global user.name vincent
git config --global user.email dzn1534564656@gmail.com
sudo nixos-rebuild switch --flake .
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system #列出nixos当前保留了哪些版本
sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system #保留最后3个版本
sudo nix-collect-garbage #删除无用的版本
```
