{pkgs, ...}: {
  services.flatpak.enable = true;
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # 只移除 GNOME 自带编辑器；其他 GNOME 应用按需手动精简
  environment.gnome.excludePackages = with pkgs; [
    gnome-text-editor
  ];
}
