{pkgs, ...}: {
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
      update = "cd /home/vincent/nixos && sudo -E nixos-rebuild switch --flake .#$(hostname)";
    };
    promptInit = ''
      export PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$ '
      export ALL_PROXY="socks5://127.0.0.1:7897"
    '';
    interactiveShellInit = ''
      unsetopt BEEP LIST_BEEP HIST_BEEP

      # 历史记录
      HISTSIZE=100000
      SAVEHIST=100000
      setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS

      ff() {
        local target="$1"
        if [ -z "$target" ]; then
          target=$(fd -t f --max-results 1 . "$HOME")
        else
          target="''${target/#\~/$HOME}"
        fi

        if [ -n "$target" ] && [ -f "$target" ]; then
          cd "$(dirname "$target")" && nvim "$(basename "$target")"
        else
          echo "ff: 文件不存在: $target"
        fi
      }

      _ff_tab_complete() {
        if [[ $BUFFER =~ '^ff[[:space:]]+(.*)$' ]]; then
          local query="$match[1]"

          if [ -z "$query" ]; then
            zle expand-or-complete
            return 0
          fi

          if [[ "$query" == */* || "$query" == \~* ]]; then
            zle expand-or-complete
            return 0
          fi

          local target
          if [ -n "$query" ]; then
            target=$(cd "$HOME" && fd -t f --max-results 200 \
                     -E .cache -E .git -E .cargo -E .rustup \
                     -E .local -E .npm -E node_modules "$query" 2>/dev/null \
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
            BUFFER="ff $HOME/$target"
            CURSOR=$#BUFFER
          fi

          zle autosuggest-clear 2>/dev/null
          zle redisplay
          return 0
        fi

        zle expand-or-complete
      }

      zle -N _ff_tab_complete
      bindkey '^I' _ff_tab_complete
    '';
  };
}
