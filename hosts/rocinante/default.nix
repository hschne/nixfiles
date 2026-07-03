{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./metal.nix
    ../../profiles/common.nix
    ../../modules/desktop.nix
    ../../modules/audio.nix
    ../../modules/apps.nix
    ../../modules/bluetooth.nix
    ../../modules/docker.nix
    ../../modules/wifi.nix
  ];

  networking.hostName = "rocinante";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  system.nixos.label = "NixOS";

  # Console/desktop login password. SSH still uses keys only. Change after
  # first boot with `passwd`.
  users.users.hschne.initialPassword = "nixos";

  system.stateVersion = "25.11";
}
