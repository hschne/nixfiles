{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [
        "--all"
        "--filter=until=720h"
      ];
    };
  };

  users.users.hschne.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
