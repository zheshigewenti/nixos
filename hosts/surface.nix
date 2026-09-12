{ ... }: {
  imports = [
    ../modules/common.nix
  ];

  networking.hostName = "surface";
  powerManagement.powertop.enable = true;
}
