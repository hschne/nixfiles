# NetworkManager with the iwd backend. Only for hosts with a WiFi adapter.
{ pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings.DriverQuirks.PowerSaveDisable = "*";

  # The mt7921e gates 5 GHz via MediaTek CLC, which is broken in recent
  # linux-firmware and hides 5 GHz APs. Disable CLC so it stops blocking them.
  boot.extraModprobeConfig = ''
    options mt7921_common disable_clc=1
  '';

  environment.systemPackages = with pkgs; [
    impala
  ];
}
