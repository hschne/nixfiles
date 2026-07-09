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
