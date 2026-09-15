{
  pkgs,
  inputs,
  ...
}: {
  # 内核与引导
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 网络与时区语言
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  # Nix 系统设置
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  # 限制 CPU 最大性能（限制发热/风扇噪声）
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/intel_pstate/max_perf_pct - - - - 80"
  ];

  # 服务
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.flatpak.enable = true;
  # 硬件与图形
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # 软件程序与特定模块配置
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.winbox = {
    enable = true;
    package = pkgs.winbox4;
    openFirewall = true;
  };

  # 用户配置
  users.users.vincent = {
    isNormalUser = true;
    description = "vincent";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # TeX 环境
      (texliveSmall.withPackages (ps:
        with ps; [
          scheme-small
          ctex
          amsmath
          titlesec
          enumitem
          geometry
          xcolor
          hyperref
          cleveref
          natbib
          fontawesome5
          lastpage
          changepage
          paracol
          needspace
          bookmark
          trimspaces
          tools
        ]))

      # 办公与日常
      google-chrome
      clash-verge-rev
      wpsoffice-cn
      zotero
      wget

      # 开发工具与CLI
      git
      lazygit
      gh
      ripgrep
      fd
      fastfetch
      hugo
      ffmpeg-full

      # 网络与诊断
      tshark
      nmap

      # 虚拟机与游戏
      quickemu
      quickgui
      steam-run
      vcmi
    ];
  };

  system.stateVersion = "25.11";
}
