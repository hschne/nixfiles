{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/syncthing.nix
    ../../modules/picoclaw.nix
  ];

  networking.hostName = "anubis";

  services.syncthing.settings.folders = {
    "Wiki" = {
      id = "um3ae-juejn";
      path = "/home/hschne/Documents/Wiki";
      devices = [ "Diskstation" ];
      type = "sendreceive";
    };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  services.qemuGuest.enable = true;

  system.stateVersion = "25.11";
}
