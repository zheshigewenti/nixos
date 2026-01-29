{
  description = "NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixvim, ... }@inputs: 
  let
    # ---------------------------------------------------------
    # 1. 公用模块 (所有主机共享的软件、Zsh、Nixvim 等)
    # ---------------------------------------------------------
    commonModule = { pkgs, config, ... }: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      networking.networkmanager.enable = true;
      time.timeZone = "Asia/Shanghai";
      i18n.defaultLocale = "zh_CN.UTF-8";
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;

      # 桌面环境
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
      
      # 基础图形支持 
      hardware.graphics = { enable = true; enable32Bit = true; };

      # 用户与软件
      users.users.vincent = {
        isNormalUser = true;
        description = "vincent";
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.zsh;
        packages = with pkgs; [
          (texlive.combine { inherit (texlive) scheme-small ctex amsmath titlesec enumitem geometry xcolor hyperref cleveref natbib fontawesome5 lastpage changepage paracol needspace bookmark trimspaces tools; })
          google-chrome firefox clash-verge-rev wechat-uos qq wpsoffice-cn ffmpeg-full shotcut zotero git lazygit gh ripgrep fd neofetch steam tshark nmap hugo
        ];
      };

      # Zsh 配置
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          update = "sudo nixos-rebuild switch --flake .#$(hostname)";
          n = "neofetch"; vi = "nvim"; lg = "lazygit";
        };
        promptInit = ''
          export http_proxy=http://127.0.0.1:7897
          export https_proxy=http://127.0.0.1:7897
          export PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$ '
        '';
      };

      # Nixvim 配置
      programs.nixvim = {
        enable = true;
        # ... (保留你原来的 Nixvim 配置)
        plugins = { treesitter.enable = true; lsp.enable = true; cmp.enable = true; telescope.enable = true; };
      };

      i18n.inputMethod = { enable = true; type = "fcitx5"; fcitx5.waylandFrontend = true; fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons fcitx5-gtk ]; };
      fonts.packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji ];
      nix.gc = { automatic = true; dates = "daily"; options = "--delete-older-than 7d"; };
      system.stateVersion = "25.11"; 
    };

    # ---------------------------------------------------------
    # 2. NVIDIA 专属模块
    # ---------------------------------------------------------
    nvidiaModule = { config, ... }: {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        open = true; # 使用现代开源内核模块
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };

  in {
    nixosConfigurations = {
      
      # --- 主机 1: XPS (纯核显) ---
      xps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./xps.nix
          nixvim.nixosModules.nixvim
          commonModule
          { networking.hostName = "xps"; }
        ];
      };

      # --- 主机 2: Surface (纯核显 + 省电) ---
      surface = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./surface.nix
          nixvim.nixosModules.nixvim
          commonModule
          { 
            networking.hostName = "surface";
            powerManagement.powertop.enable = true; 
          }
        ];
      };

      # --- 主机 3: Desktop (英伟达驱动) ---
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./desktop.nix
          nixvim.nixosModules.nixvim
          commonModule
          nvidiaModule # <--- 只有 Desktop 导入了这个显卡模块
          { networking.hostName = "desktop"; }
        ];
      };

    };
  };
}
