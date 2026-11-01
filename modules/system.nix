{...}: {
  services.journald.settings.Journal = {
    SystemMaxUse = "500M";
    RuntimeMaxUse = "100M";
  };

  zramSwap.enable = true;

  boot.kernel.sysctl."vm.swappiness" = 100;
}
