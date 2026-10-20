{
  config,
  lib,
  pkgs,
  ...
}:
let
  configDir = ./config;
  compose = import ./compose.nix { inherit config pkgs; };
  network = import ../network.nix;
in
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  environment.systemPackages = [ compose ];

  networking.firewall.interfaces.${network.lanInterface}.allowedTCPPorts = [ 443 ];

  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.immich-cloudflare-token.path;
    domains = [ "photos.schnedlitz.family" ];
    ipv4 = true;
    ipv6 = false;
    proxied = false;
    frequency = "*:0/5";
  };

  systemd.services.cloudflare-dyndns.restartTriggers = [
    config.age.secrets.immich-cloudflare-token.file
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/immich 0700 root root -"
    "d /var/lib/immich/data 0700 root root -"
    "d /var/lib/immich/data/library 0700 root root -"
    "d /var/lib/immich/model-cache 0700 root root -"
    # Match the pinned PostgreSQL image's UID/GID so activation preserves database access.
    "d /var/lib/immich/postgres 0700 999 999 -"
    "d /var/lib/immich/traefik 0700 root root -"
  ];

  systemd.services.immich = {
    description = "Immich and HTTPS proxy";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "network-online.target"
      "tailscale-online.target"
    ];
    requires = [ "docker.service" ];
    after = [
      "docker.service"
      "network-online.target"
      "tailscale-online.target"
      "systemd-tmpfiles-setup.service"
    ];
    restartTriggers = [
      configDir
      config.age.secrets.immich-cloudflare-token.file
      config.age.secrets.immich-database-env.file
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "${configDir}";
      TimeoutStartSec = "30min";
      TimeoutStopSec = 120;
      ExecStart = "${lib.getExe compose} up -d --force-recreate --wait --wait-timeout 300 --remove-orphans";
      ExecStopPost = "${lib.getExe compose} stop";
      UMask = "0077";
    };
  };
}
