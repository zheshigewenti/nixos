{...}: {
  imports = [
    ../modules/common.nix
    ../modules/nvidia.nix
  ];

  networking.hostName = "desktop";
}
