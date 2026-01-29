{
  description = "NixOS Config - Flat Multi-Host";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixvim, ... }@inputs: 
  let
    # 这里的 commonModule 包含了你所有的个人偏好设置
    # 这样 XPS 和 Surface 就能共享同一套软件和配置
    commonModule = { pkgs, config, ... }: {
      # --- 1. 核心引导与系统设置 ---
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      networking.networkmanager.enable = true;
      time.timeZone = "Asia/Shanghai";
      i18n.defaultLocale = "zh_CN.UTF-8";
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;

      # --- 2. 桌面环境 (GNOME) 与 硬件加速 ---
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      # --- 3. 用户管理与软件清单 ---
      users.users.vincent = {
        isNormalUser = true;
        description = "vincent";
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.zsh;
        packages = with pkgs; [
          (texlive.combine {
            inherit (texlive) 
            scheme-small ctex amsmath titlesec enumitem geometry xcolor 
            hyperref cleveref natbib fontawesome5 lastpage changepage 
            paracol needspace bookmark trimspaces tools;
          })
          google-chrome firefox clash-verge-rev wechat-uos qq wpsoffice-cn
          ffmpeg-full shotcut zotero git lazygit gh ripgrep fd neofetch 
          steam tshark nmap hugo
        ];
      };

      # --- 4. Zsh 终端配置 ---
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          n = "neofetch"; t = "top"; vi = "nvim"; lg = "lazygit";
          grep = "grep --color=auto -n"; ls = "ls --color=auto";
          # 智能更新命令：自动检测当前目录下的 flake
          update = "sudo nixos-rebuild switch --flake .#$(hostname)";
        };
        promptInit = ''
          export http_proxy=http://127.0.0.1:7897
          export https_proxy=http://127.0.0.1:7897
          export GTK_IM_MODULE="fcitx"
          export QT_IM_MODULE="fcitx"
          export XMODIFIERS="@im=fcitx"
          export PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$ '
        '';
      };

      # --- 5. Tmux 配置 ---
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

      # --- 6. Nixvim 配置 ---
      programs.nixvim = {
        enable = true;
        globals.mapleader = " ";
        extraConfigLua = ''
          -- Fcitx 自动切换逻辑
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
          number = true; relativenumber = true; shiftwidth = 2;
          expandtab = true; undofile = true; mouse = "a"; ignorecase = true;
        };
        plugins = {
          treesitter.enable = true;
          telescope = {
            enable = true;
            keymaps = { "<leader>ff" = "find_files"; "<leader>fg" = "live_grep"; };
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

      # --- 7. 字体与输入法 ---
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
        fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons fcitx5-gtk ];
      };
      fonts.packages = with pkgs; [ noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji ];

      # --- 8. 系统清理 ---
      nix.gc = { 
        automatic = true; 
        dates = "daily"; 
        options = "--delete-older-than 7d"; 
      };

      system.stateVersion = "25.11"; 
    };
  in {
    nixosConfigurations = {
      # 1. XPS 配置
      # 使用方法: sudo nixos-rebuild switch --flake .#xps
      xps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./xps.nix  # 对应你重命名后的原 hardware-configuration.nix
          nixvim.nixosModules.nixvim
          commonModule
          { networking.hostName = "xps"; }
        ];
      };

      # 2. Surface 配置
      # 使用方法: sudo nixos-rebuild switch --flake .#surface
      surface = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./surface.nix # 对应你未来新生成的硬件文件
          nixvim.nixosModules.nixvim
          commonModule
          { networking.hostName = "surface"; }
        ];
      };
    };
  };
}
