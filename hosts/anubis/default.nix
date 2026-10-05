{ ... }:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/syncthing.nix
  ];

  networking.hostName = "anubis";

  users.users.hschne.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLIlYScFcJcnQBZTI7RVxREIunbZoUsxkPCFFz1l/HP hschne@anubis"
  ];

  security.sudo.wheelNeedsPassword = false;

  services.syncthing.settings.folders = {
    "Wiki" = {
      id = "um3ae-juejn";
      path = "/home/hschne/Documents/Wiki";
      devices = [ "Diskstation" ];
      type = "sendreceive";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}
