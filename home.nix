{ config, pkgs, ... }:

{
  # 基础用户信息管理
  home.username = "vincent";
  home.homeDirectory = "/home/vincent"; 
  home.stateVersion = "25.11";  

  # 让 Home Manager 管理自身
  programs.home-manager.enable = true;

  # 用户级软件包安装
  home.packages = with pkgs; [
    htop        # 系统监控
    ripgrep     # 文本搜索 (Neovim 依赖)
    fd          # 文件查找 (Neovim 依赖)
    lazygit     # 终端 Git 界面
    neofetch    # 系统信息展示
    gh          # GitHub 命令行工具
  ];

  # Tmux 终端复用器配置
  programs.tmux = {
    enable = true;
    shortcut = "a";               # 前缀键改为 Ctrl-a
    baseIndex = 1;                # 窗口编号从 1 开始
    keyMode = "vi";               # 复制模式使用 vi 快捷键
    mouse = true;                 # 开启鼠标支持
    escapeTime = 0;               # 消除 Esc 延迟
    
    extraConfig = ''
      # 状态栏样式美化
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=default"
      set -g status-left "#[fg=blue,bold] 󰒓 #S #[fg=white,nobold] "
      set -g window-status-current-format "#[fg=magenta,bold] #I:#W "
      set -g status-right "#[fg=cyan,bold]%H:%M #[fg=brightblack,nobold]| #[fg=green,bold]%Y-%m-%d "

      # 使用 h/j/k/l 在面板间导航
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # 拆分窗口时保持当前路径
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      
      # 配置文件重载快捷键
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "配置已重载！"
    '';
  };

  # Zsh 终端配置
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # 命令别名
    shellAliases = {
      n = "neofetch";
      h = "htop";
      vi = "nvim";
      lg = "lazygit";
      ls = "ls --color=auto";
      update = "sudo nixos-rebuild switch --flake ."; # 一键更新系统
    };

    # 历史记录配置
    history = {
      size = 1000; 
      path = "${config.xdg.dataHome}/zsh/history"; 
      ignoreAllDups = true; 
    };

    # 初始化脚本：提示符自定义与 Git 分支显示
    initContent = ''
      # 补全不区分大小写
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      function parse_git_branch() {
        git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
      }
      setopt PROMPT_SUBST
      export PROMPT='%F{grey}%n%f %F{cyan}%~%f %F{green}$(parse_git_branch)%f %F{normal}%#%f '

      # 设置代理
      export http_proxy=http://127.0.0.1:7897
      export https_proxy=http://127.0.0.1:7897
    '';
  };

  # Neovim 编辑器基础配置
programs.nixvim = {
    enable = true;
    defaultEditor = true; # 设置为系统默认编辑器
    version.enableNixpkgsReleaseCheck = false; #消除版本不匹配警告

    # 基础设置 (opts)
    opts = {
      number = true;         # 显示行号
      relativenumber = true; # 相对行号
      shiftwidth = 2;        # 缩进
      softtabstop = 2;
      expandtab = true;
      smartindent = true;
      ignorecase = true;     # 搜索忽略大小写
      mouse = "a";           # 开启鼠标
    };


    # 插件配置 (Plugins)
    plugins = {
      # 语法高亮
      treesitter.enable = true;
      # 明确关闭图标插件
      web-devicons.enable = false; 
      # 模糊搜索
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
        };
      };

      # LSP (语言服务)
      lsp = {
        enable = true;
        servers = {
          pyright.enable = true;    # Python
          nil_ls.enable = true;     # Nix
          rust_analyzer = {         # Rust
            enable = true;
            installCargo = true;
            installRustc = true;
          };
        };
      };
      
      # 自动补全 (cmp 相关依赖)
      cmp = {
        enable = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
       # extraConfigLua = ''
       #        '';
    };

    # 全局变量 (如 Leader 键)
    globals.mapleader = " ";
  };

  # GPG 代理服务配置
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800; 
    enableSshSupport = true;
  };
}
