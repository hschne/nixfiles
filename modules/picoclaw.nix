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
      exec bash workspace/skills/picoclaw-sync/scripts/sync.sh pull
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

  systemd.services.picoclaw-restart = {
    description = "Restart PicoClaw daily";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart picoclaw.service";
    };
  };

  systemd.timers.picoclaw-restart = {
    description = "Restart PicoClaw every day at 00:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "00:00";
      Persistent = true;
      Unit = "picoclaw-restart.service";
    };
  };
}
