{ lib, pkgs, ... }:
let
  picoclaw = pkgs.callPackage ../packages/picoclaw.nix { };
  runtimePackages = with pkgs; [
    picoclaw
    chromium
    bash
    coreutils
    curl
    findutils
    git
    gnugrep
    gnused
    jq
    mise
    nodejs
    openssh
    procps
    tmux
    yq-go
  ];
  servicePath = lib.makeBinPath runtimePackages;
in
{
  environment.systemPackages = [
    picoclaw
    pkgs.chromium
  ];

  systemd.services.picoclaw = {
    description = "PicoClaw personal assistant gateway";
    documentation = [ "https://docs.picoclaw.io/" ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = runtimePackages;

    script = ''
      export PATH="/home/hschne/.scripts:/home/hschne/.local/share/mise/shims:/home/hschne/.local/bin:${servicePath}:$PATH"
      exec picoclaw gateway
    '';

    serviceConfig = {
      Type = "simple";
      User = "hschne";
      Group = "users";
      WorkingDirectory = "/home/hschne";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  systemd.services.picoclaw-sync = {
    description = "Pull PicoClaw workspace updates";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = runtimePackages;

    script = ''
      export PATH="/home/hschne/.scripts:/home/hschne/.local/share/mise/shims:/home/hschne/.local/bin:${servicePath}:$PATH"
      cd /home/hschne/.picoclaw

      old_ref="$(git rev-parse HEAD)"
      bash workspace/skills/picoclaw-sync/scripts/sync.sh pull
      new_ref="$(git rev-parse HEAD)"

      cron_changed=0
      if [[ "$old_ref" != "$new_ref" ]] && git diff --name-only "$old_ref" "$new_ref" -- workspace/cron/cron.yml | grep -qx workspace/cron/cron.yml; then
        cron_changed=1
      fi

      stale_self_sync=0
      if [[ -f workspace/cron/jobs.json ]] && jq -e '.jobs[]? | select(.name == "picoclaw-sync")' workspace/cron/jobs.json >/dev/null; then
        stale_self_sync=1
      fi

      if [[ "$cron_changed" == 1 || "$stale_self_sync" == 1 ]]; then
        bash workspace/skills/cron/scripts/setup
        touch config.json
      fi
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "hschne";
      Group = "users";
      WorkingDirectory = "/home/hschne/.picoclaw";
    };
  };

  systemd.timers.picoclaw-sync = {
    description = "Pull PicoClaw workspace updates every 30 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:03,33";
      Persistent = true;
      Unit = "picoclaw-sync.service";
    };
  };
}
