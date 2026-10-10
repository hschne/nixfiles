{ pkgs, ... }:
let
  configDir = ../services/immich;
  compose = "${pkgs.docker-compose}/bin/docker-compose --project-name immich --env-file /var/lib/immich/database.env -f ${configDir}/docker-compose.yaml";
in
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  environment.systemPackages = [ pkgs.docker-compose ];

  systemd.tmpfiles.rules = [
    "d /var/lib/immich 0700 root root -"
    "d /var/lib/immich/data 0700 root root -"
    "d /var/lib/immich/postgres 0700 root root -"
    "d /var/lib/immich/traefik 0700 root root -"
    "d /home/hschne/Pictures/Photos 2770 hschne users -"
    # Syncthing needs access to originals created by the container.
    "a+ /home/hschne/Pictures/Photos - - - - u:hschne:rwx,d:u:hschne:rwx,d:m::rwx"
  ];

  systemd.services.immich = {
    description = "Immich and private HTTPS proxy";
    wantedBy = [ "multi-user.target" ];
    wants = [ "tailscale-online.target" ];
    requires = [ "docker.service" ];
    after = [
      "docker.service"
      "tailscale-online.target"
      "systemd-tmpfiles-setup.service"
    ];
    restartTriggers = [ configDir ];
    path = with pkgs; [
      coreutils
      gnugrep
      iproute2
      openssl
    ];

    preStart = ''
      set -euo pipefail
      if [[ ! -s /var/lib/immich/cloudflare-token ]]; then
        echo "Missing /var/lib/immich/cloudflare-token; see services/immich/README.md" >&2
        exit 1
      fi
      chmod 600 /var/lib/immich/cloudflare-token

      if [[ ! -e /var/lib/immich/database.env ]]; then
        umask 077
        temp=$(mktemp /var/lib/immich/database.env.XXXXXX)
        trap 'rm -f "$temp"' EXIT
        printf 'DB_PASSWORD=%s\n' "$(openssl rand -hex 32)" > "$temp"
        mv "$temp" /var/lib/immich/database.env
      fi
      chmod 600 /var/lib/immich/database.env

      for attempt in $(seq 1 60); do
        if ip -4 -o addr show dev tailscale0 2>/dev/null | grep -q ' inet 100\.68\.130\.10/'; then
          exit 0
        fi
        sleep 2
      done
      echo "Anubis's Tailscale address is unavailable; refusing to publish HTTPS elsewhere" >&2
      exit 1
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = configDir;
      TimeoutStartSec = 600;
      TimeoutStopSec = 120;
      ExecStart = "${compose} up -d --wait --wait-timeout 300 --remove-orphans";
      ExecStop = "${compose} stop";
      UMask = "0077";
    };
  };
}
