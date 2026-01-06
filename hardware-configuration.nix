# 请勿手动修改此文件！它是由 ‘nixos-generate-config’ 自动生成的。
# 所有的手动修改都应当放在 /etc/nixos/configuration.nix 中。

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # 根分区配置
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/708d6d95-171f-43e8-b609-67d2099e0996";
      fsType = "ext4";
    };

  swapDevices = [ ];

  # 启用各网卡的 DHCP 服务
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # 开启 VirtualBox 增强功能支持
  virtualisation.virtualbox.guest.enable = true;
}
