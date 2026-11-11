{
  config,
  lib,
  ...
}: {
  imports = [
    ../modules/disko.nix
  ];

  networking.hostName = "desktop";
  # 新机器安装时按实际安装的 NixOS 版本调整
  system.stateVersion = "25.11";

  # 通用模板：每台机器装之前把这里改成目标磁盘（lsblk 确认）
  my.disk.device = "/dev/sda";

  # 硬件配置由 nixos-facter 生成的报告提供。
  # 生成方式（在目标机上）：
  #   nix run github:nix-community/nixos-facter > hosts/desktop-facter.json
  # 或在安装时让 nixos-anywhere 远程生成：
  #   --generate-hardware-config nixos-facter hosts/desktop-facter.json
  hardware.facter.reportPath = ./desktop-facter.json;

  # 通用模板：Intel / AMD 微码都带上，其余存储模块交给内核默认值
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # 机械盘上 fstrim 会报 "discard operation is not supported"；
  # 装在 SSD 上时把这行删掉即可恢复默认。
  services.fstrim.enable = lib.mkDefault false;

  # 装完即可远程访问，以后不用再碰实体机。
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };
  # 公钥放在 keys/desktop-authorized-keys.nix；为空时不设置。
  users.users.vincent.openssh.authorizedKeys.keys =
    lib.mkIf ((import ../keys/desktop-authorized-keys.nix) != [])
    (import ../keys/desktop-authorized-keys.nix);

}
