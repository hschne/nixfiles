{ lib, pkgs, ... }:
let
  network = import ../network.nix;
  home = "/home/hschne";
in
{
  services.paseo = {
    enable = true;
    user = "hschne";
    group = "users";
    dataDir = "${home}/.paseo";
    listenAddress = network.tailscaleAddress;
    openFirewall = false;
    relay.enable = false;
    inheritUserEnvironment = false;
    environment = {
      HOME = home;
      PASEO_RELAY_ENABLED = "false";
      PI_CODING_AGENT_DIR = "${home}/.pi/agent";
      PI_SUBAGENT_RUNTIME_ROOT = "${home}/.pi/agent/npm/node_modules/pi-subagents/src/agents";
    };
  };

  systemd.services.paseo = {
    environment.PATH = lib.mkForce (
      lib.concatStringsSep ":" [
        "${home}/.local/share/mise/shims"
        "${home}/.local/bin"
        "${home}/.nix-profile/bin"
        "/etc/profiles/per-user/hschne/bin"
        "/run/current-system/sw/bin"
        "/run/wrappers/bin"
      ]
    );
    wants = [ "tailscaled.service" ];
    after = [ "tailscaled.service" ];
    unitConfig.ConditionPathExists = "${home}/.paseo/config.json";
    # Do not expose agent control until the user provisions password authentication.
    serviceConfig.ExecCondition = ''${pkgs.jq}/bin/jq -e '.daemon.auth.password | strings | test("^[$]2[aby][$][0-9]{2}[$]")' ${home}/.paseo/config.json'';
  };
}
