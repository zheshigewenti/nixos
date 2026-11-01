{ pkgs, ... }: {
  environment.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";

    NIXOS_OZONE_WL = "1";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        kdePackages.fcitx5-qt
        fcitx5-gtk
      ];
    };
  };
}
