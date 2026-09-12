{ pkgs, inputs, ... }: {
  imports = [
    ./zsh.nix
    ./nixvim.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };
  
  nixpkgs.config.allowUnfree = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="module", KERNEL=="intel_pstate", ATTR{parameters/max_perf_pct}="80"
  '';

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.flatpak.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  };

  users.users.vincent = {
    isNormalUser = true;
    description = "vincent";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      (texliveSmall.withPackages (ps: with ps; [
        scheme-small ctex amsmath titlesec enumitem geometry xcolor hyperref cleveref natbib fontawesome5 lastpage changepage paracol needspace bookmark trimspaces tools
      ]))
      google-chrome flatpak clash-verge-rev wpsoffice-cn ffmpeg-full zotero git lazygit gh ripgrep fd fastfetch steam steam-run tshark nmap hugo quickemu quickgui wget vcmi
    ];
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    extraConfig = ''
      set -g mouse on
      set -g status-style "bg=default"
      set -g status-right "#{=21:pane_title} %H:%M"
      unbind '"'
      unbind %
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
    '';
  };

  programs.winbox = {
    enable = true;
    package = pkgs.winbox4;
    openFirewall = true;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons fcitx5-gtk ];
  };

  fonts = {
    packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans noto-fonts-cjk-serif noto-fonts-color-emoji ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif CJK SC" ];
      sansSerif = [ "Noto Sans CJK SC" ];
      monospace = [ "Noto Sans Mono CJK SC" ];
    };
  };

  nix.gc = { 
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
  
  system.stateVersion = "25.11";
}
