{pkgs, ...}: {
  # 输入法配置
  i18n.inputMethod = {
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-gtk
      ];
    };
  };

  # 字体配置（与中文字体渲染绑定）
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif CJK SC"];
        sansSerif = ["Noto Sans CJK SC"];
        monospace = ["Noto Sans Mono CJK SC"];
      };
    };
  };
}
