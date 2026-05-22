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
}
