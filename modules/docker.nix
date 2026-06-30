{ pkgs, ... }:
{
  virtualisation.docker.enable = true;
  users.users.hschne.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
