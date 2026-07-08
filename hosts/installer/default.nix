# Installer ISO with a working WiFi stack (the stock minimal ISO ships
# NetworkManager without a supplicant). A snapshot of this repo is bundled
# at /etc/nixfiles so installs can run without cloning.
{
  modulesPath,
  pkgs,
  self,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../modules/wifi.nix
  ];

  networking.hostName = "nixos-installer";

  environment.etc.nixfiles.source = self;

  environment.systemPackages = [ pkgs.git ];

  # Smaller image, faster build.
  documentation.enable = false;
}
