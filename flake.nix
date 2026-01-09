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
    nixvim = {
      url = "github:nix-community/nixvim";
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
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vincent = {
            imports = [
              ./home.nix
              inputs.nixvim.homeModules.nixvim
            ];
          };
        }
      ];
    };
  };
}
