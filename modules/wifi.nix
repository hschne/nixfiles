# NetworkManager with the iwd backend. Only for hosts with a WiFi adapter.
{ pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings.DriverQuirks.PowerSaveDisable = "*";

  # Without a country the regdom stays at world (00), which marks 5 GHz
  # channels no-IR (passive scan only) and hides 5 GHz APs. Set it explicitly.
  networking.wireless.iwd.settings.General.Country = "AT";

  # The mt7921e gates 5 GHz via MediaTek CLC, which is broken in recent
  # linux-firmware and hides 5 GHz APs. Disable CLC so it stops blocking them.
  boot.extraModprobeConfig = ''
    options mt7921_common disable_clc=1
  '';

  environment.systemPackages = with pkgs; [
    impala
  ];
}
