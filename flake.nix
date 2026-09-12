{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      baseConfig = {
        nixpkgs.hostPlatform = "x86_64-linux";
        imports = [
          ./modules/common.nix
          inputs.nixvim.nixosModules.nixvim
        ];
      };
    in {
      nixosConfigurations = {
        xps = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ baseConfig ./hosts/xps.nix ];
        };
        surface = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ baseConfig ./hosts/surface.nix ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ baseConfig ./hosts/desktop.nix ];
        };
      };
    };
}
