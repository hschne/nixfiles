# WiFi via NetworkManager with the iwd backend (matches the Arch setup, where
# impala is used as the WiFi TUI). Not imported on the VirtualBox VM, which
# uses NAT ethernet and has no WiFi adapter; enable this on real hardware.
{ pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;

  environment.systemPackages = with pkgs; [
    impala
  ];
}
