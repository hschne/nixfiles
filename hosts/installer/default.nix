# Bootable NixOS installer ISO for provisioning metal hosts (see the rocinante
# dual-boot runbook). Unlike the stock minimal ISO, this one has a working WiFi
# stack: NetworkManager with the iwd backend, the same as the target hosts. The
# stock minimal ISO ships NetworkManager without a supplicant, so WiFi shows up
# as unavailable.
#
# A snapshot of this repo is bundled at /etc/nixfiles so the install can run
# without cloning first.
{ modulesPath, pkgs, self, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/wifi.nix
  ];

  networking.hostName = "nixos-installer";

  environment.etc.nixfiles.source = self;

  environment.systemPackages = [ pkgs.git ];

  # No man/info pages: smaller image, faster build.
  documentation.enable = false;
}
