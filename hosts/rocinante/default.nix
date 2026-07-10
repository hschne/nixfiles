{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/syncthing.nix
    ../../modules/desktop.nix
    ../../modules/hyprland.nix
    ../../modules/theming.nix
    ../../modules/audio.nix
    ../../modules/apps.nix
    ../../modules/voxtype.nix
    ../../modules/bluetooth.nix
    ../../modules/docker.nix
    ../../modules/wifi.nix
  ];

  networking.hostName = "rocinante";

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
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.plymouth.enable = true;
  boot.plymouth.theme = "bgrt";
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  # Radeon/WiFi firmware + AMD microcode.
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  system.nixos.label = "NixOS";

  # Console login only; SSH stays key-only. Change with `passwd`.
  users.users.hschne.initialPassword = "nixos";

  system.stateVersion = "25.11";
}
