{
  description = "basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
            url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

 outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.vincent = import ./home.nix;

            # 取消注释下面这一行，就可以在 home.nix 中使用 flake 的所有 inputs 参数了
             home-manager.extraSpecialArgs = inputs;
          }
        ];
      };
    };
  };
}
