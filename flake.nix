{ description = "NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # daeuniverse.url = "github:daeuniverse/flake.nix";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: 
  let
    # =========================================================
    # 1. 核心底层：最基础的平台属性（所有配置的基石）
    # =========================================================
    baseConfig = {
      nixpkgs.hostPlatform = "x86_64-linux";
    };

    # =========================================================
    # 2. 硬件特异性模块：独立扩展层
    # =========================================================
    # NVIDIA 专属模块（仅 Desktop 需要）
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

    # =========================================================
    # 3. 公共共享模块：核心业务层（所有主机共享）
    # =========================================================
    commonModule = { pkgs, config, ... }: {
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

      # 远程登陆
      services.openssh.enable = true;
      networking.firewall.allowedTCPPorts = [ 22 ];

      # 开启 daed 服务与网页面板防火墙端口
      # services.daed = {
      #   enable = true;
      #   openFirewall = {
      #     enable = true;
      #     port = 2023;
      #   };
      # };

      # 桌面环境
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

      # 环境变量
      environment.variables = {
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
        XMODIFIERS = "@im=fcitx";
        SDL_IM_MODULE = "fcitx";
        SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
      };

      # 用户与软件
      users.users.vincent = {
        isNormalUser = true;
        description = "vincent";
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.zsh;
        packages = with pkgs; [
          (texliveSmall.withPackages (ps: with ps; [
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
          google-chrome
          flatpak
          clash-verge-rev
          wpsoffice-cn
          ffmpeg-full
          zotero
          git
          lazygit
          gh
          ripgrep
          fd
          fastfetch
          steam
          steam-run
          tshark
          nmap
          hugo
          quickemu
          quickgui
          wget
          vcmi
          # pvz-portable
        ];
      };

      # Zsh 配置
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          f = "fastfetch"; 
          t = "top"; 
          vi = "nvim"; 
          lg = "lazygit"; 
          grep = "grep --color=auto -n";
          ls = "ls --color=auto"; 
          update = "sudo nixos-rebuild switch --flake .#$(hostname)";
        };
        promptInit = ''
          export http_proxy=http://127.0.0.1:7897
          export https_proxy=http://127.0.0.1:7897
          export PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$ '
        '';
interactiveShellInit = ''
  unsetopt BEEP LIST_BEEP HIST_BEEP

  ff() {
    local target=""
    if [ -z "$1" ]; then
      target=$(fd -t f . ~ | head -n 1)
    else
      target="$1"
    fi
    
    if [ -n "$target" ]; then
      target="''${target/#\~/$HOME}"
      if [ -f "$target" ]; then
        cd "$(dirname "$target")" && nvim "$(basename "$target")"
      else
        echo "ff: 文件不存在: $target"
      fi
    fi
  }

  _ff_tab_complete() {
    if [[ $BUFFER =~ '^ff[[:space:]]+(.*)$' ]]; then
      local query="$match[1]"
      
      if [[ "$query" == */* || "$query" == \~* ]]; then
        zle expand-or-complete
        return 0
      fi

      local target
      if [ -n "$query" ]; then
        target=$(cd ~ && fd -t f -E .cache -E .git -E .cargo -E .rustup "$query" 2>/dev/null \
                 | awk -v q="$query" '
                 {
                   path = $0;
                   n = split(path, parts, "/");
                   basename = parts[n];
                   bp = tolower(basename);
                   qp = tolower(q);
                   if (index(bp, qp) == 1) score = 1;
                   else if (index(bp, qp) > 0) score = 2;
                   else score = 3;
                   print score, length(path), path;
                 }' \
                 | sort -k1,1n -k2,2n \
                 | head -n 1 \
                 | cut -d' ' -f3-)
      fi

      if [ -n "$target" ]; then
        BUFFER="ff ~/$target"
        CURSOR=$#BUFFER
        zle autosuggest-clear 2>/dev/null
        zle redisplay
        return 0
      else
        zle autosuggest-clear 2>/dev/null
        zle redisplay
        return 0
      fi
    fi
    
    zle expand-or-complete
  }
  zle -N _ff_tab_complete
  bindkey '^I' _ff_tab_complete
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
        nixpkgs.source = inputs.nixpkgs;
        globals.mapleader = " ";
        extraConfigLua = ''
          local fcitx_state = 1
          local has_fcitx = vim.fn.executable("fcitx5-remote") == 1
          if has_fcitx then
            local augroup = vim.api.nvim_create_augroup("FcitxUltimate", { clear = true })
            local function fcitx_cmd(arg) vim.fn.jobstart({"fcitx5-remote", arg}) end
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
              callback = function() if fcitx_state == 2 then fcitx_cmd("-o") end end,
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
          clipboard = "unnamedplus";
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
              clangd.enable = true;
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

      programs.winbox = {
  enable = true;
  package = pkgs.winbox4; # 明确指定使用官方原生的 WinBox 4 
  openFirewall = true;     # 开启邻居发现防火墙端口
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
          noto-fonts 
          noto-fonts-cjk-sans 
          noto-fonts-cjk-serif 
          noto-fonts-color-emoji 
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

  in {
    # =========================================================
    # 4. 最终总装层：将模块按主机各自组合
    # =========================================================
    nixosConfigurations = {
      
      # --- 主机 1: XPS ---
      xps = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          baseConfig
          ./xps.nix
          inputs.nixvim.nixosModules.nixvim
          # inputs.daeuniverse.nixosModules.daed
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
        modules = [
          baseConfig
          ./surface.nix
          inputs.nixvim.nixosModules.nixvim
          # inputs.daeuniverse.nixosModules.daed
          commonModule
          { 
            networking.hostName = "surface";
            powerManagement.powertop.enable = true; 
          }
        ];
      };

      # --- 主机 3: Desktop ---
      desktop = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          baseConfig
          ./desktop.nix
          inputs.nixvim.nixosModules.nixvim
          # inputs.daeuniverse.nixosModules.daed
          commonModule
          nvidiaModule
          { networking.hostName = "desktop"; }
        ];
      };
    };
  };
}
