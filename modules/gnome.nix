{pkgs, ...}: {
  services.flatpak.enable = true;
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # 精简不常用的 GNOME 自带应用
  environment.gnome.excludePackages = with pkgs; [
    gnome-text-editor
    gnome-tour
    gnome-user-docs
    yelp
    epiphany
    gnome-maps
    gnome-weather
    gnome-music
    gnome-contacts
    gnome-calendar
    gnome-clocks
    gnome-logs
    gnome-system-monitor
    gnome-font-viewer
    baobab
    simple-scan
    snapshot
    decibels
    gnome-initial-setup
    gnome-user-share
    gnome-color-manager
    gnome-browser-connector
    gnome-online-accounts
  ];
}
