{...}: {
  # Clash Verge Rev：systemd 服务 + TUN 所需权限
  # 包本身由 nixpkgs 的 programs.clash-verge 模块装进 environment.systemPackages
  programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
  };
}
