{
  config,
  ...
}: {
  imports = [
    ./desktop-hardware.nix
  ];

  networking.hostName = "desktop";
  # 新机器安装时按实际安装的 NixOS 版本调整
  system.stateVersion = "25.11";

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
