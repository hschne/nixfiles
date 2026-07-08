{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/syncthing.nix
    ../../modules/picoclaw.nix
  ];

  networking.hostName = "anubis";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  services.qemuGuest.enable = true;

  system.stateVersion = "25.11";
}
