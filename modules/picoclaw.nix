{ pkgs, ... }:
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
      export PATH="/home/hschne/.scripts:/home/hschne/.local/share/mise/shims:/home/hschne/.local/bin:$PATH"
      exec picoclaw gateway
    '';

    serviceConfig = {
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
      export PATH="/home/hschne/.scripts:/home/hschne/.local/share/mise/shims:/home/hschne/.local/bin:$PATH"
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
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:03,33";
      Persistent = true;
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
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "00:00";
      Persistent = true;
    };
  };
}
