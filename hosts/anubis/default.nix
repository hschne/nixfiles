{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/common.nix
    ../../modules/qemu-guest.nix
    ../../modules/picoclaw.nix
  ];

  networking.hostName = "anubis";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  system.stateVersion = "25.11";
}
