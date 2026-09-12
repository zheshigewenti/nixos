{inputs, ...}: let
  baseConfig = {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = [
      ../modules/common.nix
      ../modules/tmux.nix
      ../modules/input-method.nix
      ../modules/nixvim.nix
      ../modules/zsh.nix
      inputs.nixvim.nixosModules.nixvim
    ];
  };
in {
  flake.nixosConfigurations = {
    xps = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [baseConfig ../hosts/xps.nix];
    };

    surface = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [baseConfig ../hosts/surface.nix];
    };

    desktop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [baseConfig ../hosts/desktop.nix];
    };
  };
}
