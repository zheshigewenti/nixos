{
  config,
  lib,
  inputs,
  ...
}: {
  imports = [inputs.disko.nixosModules.disko];

  options.my.disk.device = lib.mkOption {
    type = lib.types.str;
    description = ''
      要交给 disko 的整块磁盘，例如 /dev/nvme0n1 或 /dev/sda。
      用 lsblk 确认，注意不要填成某个分区（/dev/nvme0n1p1）。
    '';
  };

  config.disko.devices = {
    disk.main = {
      type = "disk";
      device = config.my.disk.device;
      content = {
        type = "gpt";
        partitions = {
          # EFI System Partition，挂到 /boot
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };

          # 剩余空间全部给根分区；不建 swap，用 zram
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = ["noatime"];
            };
          };
        };
      };
    };
  };
}
