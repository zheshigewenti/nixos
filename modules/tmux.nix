{pkgs, ...}: {
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
}
