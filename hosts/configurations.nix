{inputs, ...}: let
  commonModules = [
    ../modules/common.nix
    inputs.nixvim.nixosModules.nixvim
  ];
  hosts = ["xps" "desktop"];
in {
  flake.nixosConfigurations = inputs.nixpkgs.lib.genAttrs hosts (host:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = commonModules ++ [./${host}.nix];
    });
}
