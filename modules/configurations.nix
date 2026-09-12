{inputs, ...}: let
  commonModules = [
    ./common.nix
    ./tmux.nix
    ./input-method.nix
    ./nixvim.nix
    ./zsh.nix
    inputs.nixvim.nixosModules.nixvim
  ];
in {
  flake.nixosConfigurations = {
    xps = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = commonModules ++ [../hosts/xps.nix];
    };

    surface = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = commonModules ++ [../hosts/surface.nix];
    };

    desktop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = commonModules ++ [../hosts/desktop.nix];
    };
  };
}
