{pkgs, ...}: let
  # OpenTUI 通过 dlopen 使用 libwayland-client/libxcb；nixpkgs 的 opencode
  # 只带了 wayland，GNOME 下 Wayland 后端不可用时会退回 X11，需要 libxcb。
  opencodeFixed = pkgs.writeShellScriptBin "opencode" ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [pkgs.libxcb pkgs.wayland pkgs.stdenv.cc.cc.lib]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    exec ${pkgs.opencode}/bin/opencode "$@"
  '';
in {
  users.users.vincent = {
    isNormalUser = true;
    description = "vincent";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # TeX 环境
      (texliveSmall.withPackages (ps:
        with ps; [
          ctex
          titlesec
          enumitem
          cleveref
          fontawesome5
          lastpage
          changepage
          paracol
          needspace
          trimspaces
        ]))

      # 办公与日常
      google-chrome
      opencodeFixed
      clash-verge-rev
      wpsoffice-cn
      # zotero
      wget

      # 开发工具与CLI
      git
      lazygit
      gh
      ripgrep
      fd
      fastfetch
      hugo
      ffmpeg

      # 剪贴板（Wayland）
      wl-clipboard

      # 网络与诊断
      tshark
      nmap

      # 虚拟机与游戏
      quickgui
      virt-viewer
      steam-run
      vcmi
    ];
  };
}
