{ config, pkgs }:
let
  network = import ../network.nix;
  secrets = config.age.secrets;
in
pkgs.writeShellApplication {
  name = "immich-compose";
  runtimeInputs = [ pkgs.docker-compose ];
  runtimeEnv = {
    COMPOSE_PROJECT_NAME = "immich";
    COMPOSE_FILE = "${./config}/docker-compose.yaml";
    COMPOSE_ENV_FILES = secrets.immich-database-env.path;
    CLOUDFLARE_TOKEN_FILE = secrets.immich-cloudflare-token.path;
    IMMICH_LAN_ADDRESS = network.lanAddress;
    IMMICH_TAILSCALE_ADDRESS = network.tailscaleAddress;
  };
  text = ''exec docker-compose "$@"'';
}
