# NetworkManager with the iwd backend. Only for hosts with a WiFi adapter.
{ pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings.DriverQuirks.PowerSaveDisable = "*";

  environment.systemPackages = with pkgs; [
    impala
  ];
}
