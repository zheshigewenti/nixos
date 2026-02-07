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

      # 远程登陆
      services.openssh.enable = true;
      networking.firewall.allowedTCPPorts = [ 22 ];

      # 桌面环境
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
      
      # 基础图形支持 
      hardware.graphics = { enable = true; enable32Bit = true; };

      # 环境变量
      environment.variables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
      NIXOS_OZONE_WL = "1";
  };

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
          n = "neofetch"; t = "top"; vi = "nvim"; lg = "lazygit"; grep = "grep --color=auto -n";
          ls = "ls --color=auto"; update = "sudo nixos-rebuild switch --flake .#$(hostname)";

        };
        promptInit = ''
              # 代理设置
              export http_proxy=http://127.0.0.1:7897
              export https_proxy=http://127.0.0.1:7897
              # 提示符设置
              export PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$ '
        '';
      };
     
       # Tmux 配置
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

      # Nixvim 配置
       programs.nixvim = {
            enable = true;
            globals.mapleader = " ";
            extraConfigLua = ''
            local fcitx_state = 1
            local has_fcitx = vim.fn.executable("fcitx5-remote") == 1
            
            if has_fcitx then
                local augroup = vim.api.nvim_create_augroup("FcitxUltimate", { clear = true })
                
                local function fcitx_cmd(arg)
                    vim.fn.jobstart({"fcitx5-remote", arg})
                end
            
                vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
                    group = augroup,
                    callback = function()
                        local handle = io.popen("fcitx5-remote")
                        if handle then
                            local status = tonumber(handle:read("*all"))
                            handle:close()
                            fcitx_state = status or 1
                            if fcitx_state == 2 then fcitx_cmd("-c") end
                        end
                    end,
                })
            
                vim.api.nvim_create_autocmd("InsertEnter", {
                    group = augroup,
                    callback = function()
                        if fcitx_state == 2 then fcitx_cmd("-o") end
                    end,
                })
            end
            '';
            defaultEditor = true;
            opts = {
              number = true;
              relativenumber = true;
              shiftwidth = 2;
              expandtab = true;
              undofile = true;
              mouse = "a";
              ignorecase = true;
            };
            plugins = {
              web-devicons.enable = false;
              treesitter.enable = true;
              telescope = {
                 enable = true;
                  keymaps = {
                  "<leader>ff" = "find_files";    # 查找文件
                  "<leader>fg" = "live_grep";     # 全局搜索文本
                };
              };
              lsp = {
                enable = true;
                servers = {
                  # pyright.enable = true;
                  nil_ls.enable = true;
                  texlab.enable = true;
                  marksman.enable = true;
                  html.enable = true;
                  cssls.enable = true;
                };
              };

               cmp = {
                 enable = true;
                 settings = {
                   # 映射必须是属性集，每个映射后面跟分号
                   mapping = {
                     "<C-n>" = "cmp.mapping(function(fallback) fallback() end, { 'i', 'c' })";
                     "<C-p>" = "cmp.mapping(function(fallback) fallback() end, { 'i', 'c' })";
                     "<Tab>" = "cmp.mapping.select_next_item()";
                     "<S-Tab>" = "cmp.mapping.select_prev_item()";
                     "<CR>" = "cmp.mapping.confirm({ select = true })";
                   }; 
                   sources = [
                     { name = "nvim_lsp"; }
                     { name = "buffer"; }
                     { name = "path"; }
                   ];
                 }; # 这里结束 settings
               }; # 这里结束 plugins.cmp
            };
          };

	# 字体、中文输入法
          i18n.inputMethod = {
            enable = true;
            type = "fcitx5";
            fcitx5.waylandFrontend = true;
            fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons fcitx5-gtk];
          };

          fonts = {
            packages = with pkgs; [ 
              noto-fonts noto-fonts-cjk-sans noto-fonts-cjk-serif noto-fonts-color-emoji 
            ];
            fontconfig.defaultFonts = {
              serif = [ "Noto Serif CJK SC" ];
              sansSerif = [ "Noto Sans CJK SC" ];
              monospace = [ "Noto Sans Mono CJK SC" ];
            };
          };



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
