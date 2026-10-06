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
    "Documents" = {
      id = "d6pbp-k3jur";
      path = "/home/hschne/Documents";
      devices = [ "Diskstation" ];
      type = "sendreceive";
    };
    "Pictures" = {
      id = "7epys-jcu7w";
      path = "/home/hschne/Pictures";
      devices = [ "Diskstation" ];
      type = "sendreceive";
    };
    "Videos" = {
      id = "dxnw7-fqqfc";
      path = "/home/hschne/Videos";
      devices = [ "Diskstation" ];
      type = "sendreceive";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}
