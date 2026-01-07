{ config, pkgs, ... }:

{
  imports =
    [ # 导入硬件扫描生成的硬件配置文件
      ./hardware-configuration.nix
    ];

  # # 独显设置
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false; # 如果笔记本合盖有问题，设为 true
  #   powerManagement.finegrained = false;
  #
  #   # 解决你报错的关键行
  #   open = true; 
  #
  #   # 启用设置界面
  #   nvidiaSettings = true;
  #
  #   # 选择驱动版本（通常默认即可，除非有特殊需求）
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };
  #
  # # 开启硬件加速
  # hardware.graphics = {
  #   enable = true;
  #   enable32Bit = true;
  # };

  # 启用 Flake 实验性功能
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # 开启优化存储，自动合并相同文件
  nix.settings.auto-optimise-store = true;

  # 启用 Zsh 终端
  programs.zsh.enable = true;

  # 引导加载程序 (Grub) 配置
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # 网络主机名设置
  networking.hostName = "nixos"; 

  # 启用 NetworkManager 管理网络
  networking.networkmanager.enable = true;

  # 防火墙设置
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ]; # 根据需要开放
    # checkReversePath = false; # 局域网信任
  };

  # 设置时区为亚洲/上海
  time.timeZone = "Asia/Shanghai";

  # 国际化语言环境设置
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # 输入法配置 (Fcitx5)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true; # 开启 Wayland 原生支持
      addons = with pkgs; [
       qt6Packages.fcitx5-chinese-addons # 核心中文插件（含拼音）
        fcitx5-gtk            # GTK 应用支持
        fcitx5-material-color             # 皮肤主题
      ];
    };
  };

  # 全局环境变量设置
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # 启用 X11 窗口系统
  services.xserver.enable = true;

  # 启用 GNOME 桌面环境
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # X11 键盘布局配置
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # 启用打印服务
  services.printing.enable = true;

  # 启用 Pipewire 音频服务
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # 定义用户帐户
  users.users.vincent = {
    isNormalUser = true;
    description = "vincent";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      git
      neovim
      lazygit
      google-chrome
    ];
  };

  # 字体配置（解决网页乱码的关键）
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans   # Google 中文黑体
      noto-fonts-cjk-serif  # Google 中文宋体
      noto-fonts-color-emoji # 彩色表情
    ];

    # 字体渲染优化与默认映射
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Noto Sans Mono CJK SC" ];
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
      };
    };
  };

  # 允许安装闭源软件（如Chrome）
  nixpkgs.config.allowUnfree = true;

  # 允许加载闭源固件（如WiFi驱动）
  hardware.enableAllFirmware = true;

  # 系统全局软件包
  environment.systemPackages = with pkgs; [
    gnomeExtensions.kimpanel # GNOME 输入法托盘图标支持
  ];

  #自动清理设置
  nix.gc = {
    automatic = true;      # 开启自动清理
    dates = "daily";      # 每天执行一次 
    options = "--delete-older-than 7d"; # 清理超过7天前的旧版本
  };


  # 系统状态版本，建议保持初次安装时的设定
  system.stateVersion = "25.11"; 
}
