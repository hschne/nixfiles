{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
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
