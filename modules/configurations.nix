{inputs, ...}: let
  commonModules = [
    ./common.nix
    ./tmux.nix
    ./input-method.nix
    ./nixvim.nix
    ./zsh.nix
    inputs.nixvim.nixosModules.nixvim
  ];
  hosts = ["xps" "desktop"];
in {
  flake.nixosConfigurations = inputs.nixpkgs.lib.genAttrs hosts (host:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = commonModules ++ [../hosts/${host}.nix];
    });
}
