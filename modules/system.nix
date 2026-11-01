{...}: {
  services.journald.settings.Journal.SystemMaxUse = "500M";

  zramSwap.enable = true;

  system.stateVersion = "25.11";
}
