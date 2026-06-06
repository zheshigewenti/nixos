{
  description = "NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: 
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
      
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
      };
      
      nixpkgs.config.allowUnfree = true;

      # 远程登陆
      services.openssh.enable = true;
      networking.firewall.allowedTCPPorts = [ 22 ];

      # 桌面环境
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true; # 绝对不能删
        extraPackages = with pkgs; [
        intel-media-driver
        ];
            };

      # 环境变量
      environment.variables = {
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
        XMODIFIERS = "@im=fcitx";
        SDL_IM_MODULE = "fcitx";
      };

      # 用户与软件
      users.users.vincent = {
        isNormalUser = true;
        description = "vincent";
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.zsh;
        packages = with pkgs; [
          (texlive.combine { inherit (texlive) scheme-small ctex amsmath titlesec enumitem geometry xcolor hyperref cleveref natbib fontawesome5 lastpage changepage paracol needspace bookmark trimspaces tools; })
          google-chrome firefox clash-verge-rev qq wpsoffice-cn ffmpeg-full shotcut zotero git lazygit gh ripgrep fd fastfetch steam tshark nmap hugo quickemu quickgui
        ];
      };

      # Zsh 配置
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          f = "fastfetch"; t = "top"; vi = "nvim"; lg = "lazygit"; grep = "grep --color=auto -n";
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
        nixpkgs.source = pkgs;
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
              "<leader>ff" = "find_files";
              "<leader>fg" = "live_grep";
            };
          };
          lsp = {
            enable = true;
            servers = {
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
            };
          };
        };
      };

      # 字体、中文输入法
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
        fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons fcitx5-gtk ];
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

      nix.gc = { 
        automatic = true; 
        dates = "daily"; 
        options = "--delete-older-than 7d"; 
      };
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
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };

  in {
    nixosConfigurations = {
      
# --- 主机 1: XPS ---
      xps = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # 优化点 2: 统一使用 inputs. 前缀调用
        modules = [
          ./xps.nix
          inputs.nixvim.nixosModules.nixvim
          commonModule
          {
            networking.hostName = "xps"; 
            boot.extraModprobeConfig = ''
              blacklist i8k
              blacklist dell_wmi_ddv
              blacklist dell_smm_hwmon
              blacklist dell_smm
            '';
            boot.blacklistedKernelModules = [ 
              "dell_wmi_ddv" 
              "i8k" 
              "dell_smm_hwmon" 
              "dell_smm" 
            ];
          }
        ];
      };

      # --- 主机 2: Surface ---
      surface = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./surface.nix
          inputs.nixvim.nixosModules.nixvim
          commonModule
          { 
            networking.hostName = "surface";
            powerManagement.powertop.enable = true; 
          }
        ];
      };

      # --- 主机 3: Desktop ---
      desktop = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./desktop.nix
          inputs.nixvim.nixosModules.nixvim
          commonModule
          nvidiaModule
          { networking.hostName = "desktop"; }
        ];
      };
    };
  };
}
