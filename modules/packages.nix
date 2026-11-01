{pkgs, ...}: {
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
      opencode
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

      # 网络与诊断
      tshark
      nmap

      # 虚拟机与游戏
      quickgui
      steam-run
      vcmi
    ];
  };
}
