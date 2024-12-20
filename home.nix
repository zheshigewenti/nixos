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
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
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
    syntaxHighlighting.enable = true;

  shellAliases = {
    l = "lazygit";
    h = "htop";
    ls = "ls --color";
    update = "sudo nixos-rebuild switch --flake .";
    };
  history = {
    size = 1000;
    path = "${config.xdg.dataHome}/zsh/history";
   };
 };

}
