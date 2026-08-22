{ ... }:
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = "weekly";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxRetentionSec=30day
  '';

  boot.tmp.cleanOnBoot = true;

  systemd.coredump.settings.Coredump = {
    MaxUse = "1G";
    KeepFree = "5G";
  };
}
