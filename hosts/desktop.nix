{
  config,
  lib,
  ...
}: {
  imports = [
    ../modules/disko.nix
    ./desktop-hardware.nix
  ];

  networking.hostName = "desktop";
  # 新机器安装时按实际安装的 NixOS 版本调整
  system.stateVersion = "25.11";

  # 通用模板：每台机器装之前把这里改成目标磁盘（lsblk 确认）
  my.disk.device = "/dev/nvme0n1";

  # 通用模板：Intel / AMD 微码都带上，其余存储模块交给内核默认值
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # 机械盘上 fstrim 会报 "discard operation is not supported"；
  # 装在 SSD 上时把这行删掉即可恢复默认。
  services.fstrim.enable = lib.mkDefault false;

  # 注意：这段是 NVIDIA 专用。装到非 NVIDIA 机器上时删掉/注释掉。
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
