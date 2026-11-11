{...}: {
  # 磁盘分区、格式化和 fileSystems 现在由 modules/disko.nix 负责。
  # 这个文件只保留 nixos-generate-config 生成的硬件部分（内核模块、CPU 微码等）。
  #
  # 生成命令（注意 --no-filesystems，否则会和 disko 冲突）：
  #   nixos-generate-config --no-filesystems --show-hardware-config \
  #     > hosts/desktop-hardware.nix
}
