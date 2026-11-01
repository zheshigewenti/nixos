{pkgs, ...}: {
  # 内核与引导（使用稳定内核，减少滚动更新和不必要的重建）
  boot.kernelPackages = pkgs.linuxPackages;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  boot.tmp.cleanOnBoot = true;
}
