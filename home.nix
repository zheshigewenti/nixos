{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------------
  # 1. 基础用户信息管理
  # -----------------------------------------------------------------------------
  home.username = "vincent"; 
  home.homeDirectory = "/home/vincent"; 
  home.stateVersion = "24.11";  

  # 让 Home Manager 管理自身
  programs.home-manager.enable = true;

  # -----------------------------------------------------------------------------
  # 2. 软件包安装
  # -----------------------------------------------------------------------------
  home.packages = with pkgs; [
    # 核心工具
    htop
    fcitx5
    ripgrep     # Neovim 搜索依赖
    fd          # Neovim 文件查找依赖
    lazygit     # 终端 Git UI
    neofetch    # 系统信息展示
    gh
  ];

  # -----------------------------------------------------------------------------
  # 3. 程序详细配置 (声明式)
  # -----------------------------------------------------------------------------

  # Git 配置
  programs.git = {
    enable = true;
    userName = "vincent";
    userEmail = "dzn1534564656@gmail.com"; 
  };

  # Tmux 配置 (原生逻辑替代插件)
  programs.tmux = {
    enable = true;
    shortcut = "a";               # 前缀键 C-a
    baseIndex = 1;                # 窗口编号从 1 开始
    keyMode = "vi";               # 复制模式使用 vi 键位
    mouse = true;                 # 开启鼠标支持
    escapeTime = 0;               # 消除 Esc 延迟
    
    # 注入你打磨的原生配置和状态栏美化
    extraConfig = ''
      # 状态栏样式：统一加粗
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=default"
      set -g status-left "#[fg=blue,bold] 󰒓 #S #[fg=white,nobold] "
      set -g window-status-current-format "#[fg=magenta,bold] #I:#W "
      set -g status-right "#[fg=cyan,bold]%H:%M #[fg=brightblack,nobold]| #[fg=green,bold]%Y-%m-%d "

      # 面板导航 h/j/k/l
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # 保持当前路径拆分
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      
      # 配置重载
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
    '';
  };

  # Zsh 配置
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true; # 建议开启，提升终端体验

    # 别名设置
    shellAliases = {
      n = "neofetch";
      h = "htop";
      vi = "nvim";
      lg = "lazygit";
      ls = "ls --color=auto";
      update = "sudo nixos-rebuild switch --flake .";  
    };

    # 历史记录管理
    history = {
      size = 1000; 
      path = "${config.xdg.dataHome}/zsh/history"; 
      ignoreAllDups = true; 
    };

    # 提示符与额外脚本
    initExtra = ''
      # 不区分大小写补全 
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      # Git 分支显示逻辑
      function parse_git_branch() {
        git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
      }
      setopt PROMPT_SUBST
      export PROMPT='%F{grey}%n%f %F{cyan}%~%f %F{green}$(parse_git_branch)%f %F{normal}%#%f '
    '';
  };

  # Neovim 基础设置 (混合模式)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # 建议此处保持为空，通过 home.file 将你现有的 init.lua 挂载进来
  };

  # -----------------------------------------------------------------------------
  # 4. 服务与文件映射 [cite: 5]
  # -----------------------------------------------------------------------------
  services.gpg-agent = {
    enable = true; # [cite: 5]
    defaultCacheTtl = 1800; # [cite: 5]
    enableSshSupport = true; # [cite: 5]
  };

  # 映射 Neovim 配置目录 (假设你的配置在 flake 同级目录下的 nvim 文件夹)
  # home.file.".config/nvim".source = ./nvim;

}
