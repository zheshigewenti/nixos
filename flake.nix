{
  description = "NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # 使用 Nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixvim, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # aarch64-linux
      modules = [
        # 引用由脚本自动生成的硬件配置文件
        ./hardware-configuration.nix
        nixvim.nixosModules.nixvim
        
        ({ pkgs, config, ... }: {
          # --- 1. 核心引导与系统设置 ---
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          networking.hostName = "nixos";
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
                scheme-small
                ctex          # 中文核心支持
                amsmath       # 数学公式
                titlesec      # 标题样式
                enumitem      # 列表样式
                geometry      # 页面边距
                xcolor        # 颜色处理
                hyperref      # 链接与 PDF 书签
                cleveref      # 智能交叉引用
                natbib        # 参考文献管理
                fontawesome5  # 修复图标缺失 
                lastpage      # 修复页码计算 
                changepage    # 修复边距调整
                paracol       # 修复双栏/日期对齐
                needspace     # 修复分页逻辑
                bookmark      # 修复书签增强支持
                trimspaces    # 处理字符空格
                tools;

              })
              google-chrome
              clash-verge-rev
              wechat-uos 
              wpsoffice-cn
              ffmpeg-full 
              shotcut 
              zotero
              git
              lazygit 
              gh
              htop 
              ripgrep
              fd 
              neofetch
              steam
              wireshark
              nmap
            ];
          };

          # --- 4. Zsh 终端配置  ---
          programs.zsh = {
            enable = true;
            enableCompletion = true;
            autosuggestions.enable = true;
            syntaxHighlighting.enable = true;
            shellAliases = {
              n = "neofetch"; h = "htop"; vi = "nvim"; lg = "lazygit";
              ls = "ls --color=auto";
              update = "sudo nixos-rebuild switch --flake .#nixos";
            };
            promptInit = ''
              # 代理设置
              export http_proxy=http://127.0.0.1:7897
              export https_proxy=http://127.0.0.1:7897
              # 输入法设置
              export GTK_IM_MODULE="fcitx"
              export QT_IM_MODULE="fcitx"
              export XMODIFIERS="@im=fcitx"
              # 提示符设置
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
              bind h select-pane -L
              bind j select-pane -D
              bind k select-pane -U
              bind l select-pane -R
            '';
          };

          # --- 6. Nixvim 配置  ---
          programs.nixvim = {
            enable = true;
            globals.mapleader = " ";
            extraConfigLua = ''
            local fcitx_state = 1
            local augroup = vim.api.nvim_create_augroup("FcitxAsync", { clear = true })
            
            local function fcitx_cmd(arg)
                vim.fn.jobstart({"fcitx5-remote", arg})
            end
            
            vim.api.nvim_create_autocmd("InsertLeave", {
                group = augroup,
                callback = function()
                    vim.fn.jobstart({"fcitx5-remote"}, {
                        on_stdout = function(_, data)
                            local status = data and tonumber(data[1])
                            if status == 2 then
                                fcitx_state = 2
                                fcitx_cmd("-c")
                            else
                                fcitx_state = 1
                            end
                        end
                    })
                end,
            })
            
            vim.api.nvim_create_autocmd("InsertEnter", {
                group = augroup,
                callback = function()
                    if fcitx_state == 2 then
                        fcitx_cmd("-o")
                    end
                end,
            })
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
                  pyright.enable = true;
                  nil_ls.enable = true;
                  texlab.enable = true;
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

          # --- 7. 字体、中文支持与输入法 ---
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

          # --- 8. 系统自动化与清理 ---
          nix.gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 7d";
          };
          
          services.openssh.enable = true;
          networking.firewall.allowedTCPPorts = [22];

          system.stateVersion = "25.11"; 
        })
      ];
    };
  };
}
