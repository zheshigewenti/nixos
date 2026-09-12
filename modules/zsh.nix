{ pkgs, ... }: {
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
      export PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$ '
    '';
    interactiveShellInit = ''
      unsetopt BEEP LIST_BEEP HIST_BEEP

      ff() {
        local target="$1"
        if [ -z "$target" ]; then
          target=$(fd -t f . "$HOME" | head -n 1)
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
          
          if [[ "$query" == */* || "$query" == \~* ]]; then
            zle expand-or-complete
            return 0
          fi

          local target
          if [ -n "$query" ]; then
            target=$(cd "$HOME" && fd -t f -E .cache -E .git -E .cargo -E .rustup "$query" 2>/dev/null \
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
