{ pkgs, ... }:
let
  # Offload GPU processing via vulkan
  voxtype = pkgs.callPackage ../packages/voxtype.nix { variant = "vulkan"; };
in
{
  systemd.user.services.voxtype = {
    description = "Voxtype push-to-talk voice-to-text daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${voxtype}/bin/voxtype daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Push to talk requires access to input group
  users.users.hschne.extraGroups = [ "input" ];

  environment.systemPackages = [ voxtype ];
}
