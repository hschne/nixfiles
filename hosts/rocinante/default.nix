{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./vm.nix
    ../../profiles/common.nix
    ../../modules/desktop.nix
    ../../modules/audio.nix
    ../../modules/apps.nix
    ../../modules/bluetooth.nix
    ../../modules/docker.nix
  ];

  networking.hostName = "rocinante";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  # Console/desktop login password. SSH still uses keys only.
  users.users.hschne.initialPassword = "nixos";

  system.stateVersion = "25.11";
}
