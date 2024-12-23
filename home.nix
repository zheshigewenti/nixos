{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "vincent";
  home.homeDirectory = "/home/vincent";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs;[
    htop
    fcitx5
    tmux
  ];

  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
  programs.git = {
    enable = true;
    userName = "vincent";
    userEmail = "dzn1534564656@gmail.com";
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = false;
    initExtra = ''
# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


# git branch prompt
function parse_git_branch() {git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'}
setopt PROMPT_SUBST
export PROMPT='%F{grey}%n%f %F{cyan}%~%f %F{green}$(parse_git_branch)%f %F{normal}%#%f '
      '';
  shellAliases = {
    n = "neofetch";
    h = "htop";
    vi = "nvim";
    lg = "lazygit";
    ld = "lazydocker";
    ls = "ls --color";
    update = "sudo nixos-rebuild switch --flake .";
    };
  history = {
    size = 1000;
    path = "${config.xdg.dataHome}/zsh/history";
    ignoreAllDups = true;
   };
 };

}
