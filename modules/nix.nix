{...}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
    randomizedDelaySec = "1h";
  };

  nixpkgs.config.allowUnfree = true;
}
