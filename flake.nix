{
  description = "Vincent's NixOS Flake Configuration";

  inputs = {
    # 使用最新的稳定版
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # 用户级配置管理器
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # 'nixos' 需要替换为你 configuration.nix 里的 networking.hostName
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.vincent = import ./home.nix;
        }
      ];
    };
  };
}
