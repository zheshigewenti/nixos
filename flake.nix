{
  description = "Vincent 的 NixOS Flake 配置文件";

  inputs = {
    # 使用 NixOS 25.11 稳定版分支
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # 用户级配置管理器
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # 'nixos' 必须与 configuration.nix 中的 networking.hostName 一致
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        # 整合 Home-Manager 模块到系统配置中
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vincent = import ./home.nix;
        }
      ];
    };
  };
}
