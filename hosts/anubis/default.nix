{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base.nix
    ../../modules/ssh.nix
    ../../modules/github-ssh.nix
    ../../modules/tailscale.nix
    ../../modules/qemu-guest.nix
    ../../modules/syncthing.nix
  ];

  networking.hostName = "anubis";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  system.stateVersion = "25.11";
}
