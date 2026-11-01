{...}: {
  # 这个文件由新机器生成后覆盖，例如：
  #   ssh root@新机器IP 'nixos-generate-config --show-hardware-config' \
  #     > hosts/desktop-hardware.nix
  #
  # 生成前 desktop 缺少 fileSystems，构建失败是预期的。
}
