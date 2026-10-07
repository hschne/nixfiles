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

  systemd.services.syncthing = {
    wants = [ "tailscale-online.target" ];
    after = [ "tailscale-online.target" ];
  };

  # Bind the GUI only to anubis's address on the personal tailnet.
  services.syncthing.guiAddress = "100.68.130.10:8384";
  services.syncthing.settings.gui = {
    user = "hschne";
    password = "$2y$12$8rLPSS8QcaMp5kuyXTwwXef92w5LvS8euGbtTFIISxSKBGaHreV5C";
  };

  services.syncthing.settings.devices = {
    "Rocinante".id = "UZX3NJJ-JSX23A7-DJWVQLF-CH3WZ22-ZF7HDDA-KJFYCDB-73QL5UV-VDKIWQC";
    "Razorback".id = "ITSPZ2K-QWJ3VKQ-FTXAPCI-ROXWOR7-42KP7SY-3WG6CXZ-VY3YXSS-4DBI6QN";
  };

  services.syncthing.settings.folders = {
    "Documents" = {
      id = "d6pbp-k3jur";
      path = "/home/hschne/Documents";
      devices = [
        "Diskstation"
        "Rocinante"
        "Razorback"
      ];
      type = "sendreceive";
    };
    "Pictures" = {
      id = "7epys-jcu7w";
      path = "/home/hschne/Pictures";
      devices = [
        "Diskstation"
        "Rocinante"
        "Razorback"
      ];
      type = "sendreceive";
    };
    "Videos" = {
      id = "dxnw7-fqqfc";
      path = "/home/hschne/Videos";
      devices = [
        "Diskstation"
        "Rocinante"
        "Razorback"
      ];
      type = "sendreceive";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}
