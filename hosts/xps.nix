{
  pkgs,
  ...
}: {
  imports = [
    ./xps-hardware.nix
  ];

  networking.hostName = "xps";

  # 减少 SSD 上的 atime 写入
  fileSystems."/".options = ["noatime"];

  # XPS 是 Intel 核显，需要 Intel 的 VA-API 驱动
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
  ];

  # xps 需要的远程访问
  networking.firewall.allowedTCPPorts = [22 3389];
  networking.firewall.allowedUDPPorts = [3389];

  services.openssh.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;

  # Intel 笔记本电源/温度管理
  services.thermald.enable = true;

  # tshark 抓包权限
  programs.wireshark = {
    enable = true;
    package = pkgs.tshark;
  };
  users.users.vincent.extraGroups = ["wireshark"];

  # Dell 风扇/背光模块在这台机器上有问题
  boot.blacklistedKernelModules = [
    "dell_wmi_ddv"
    "i8k"
    "dell_smm_hwmon"
    "dell_smm"
  ];

  # 限制 CPU 最大性能（限制发热/风扇噪声）
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/intel_pstate/max_perf_pct - - - - 80"
    "w /sys/devices/system/cpu/intel_pstate/no_turbo - - - - 1"
  ];
}
