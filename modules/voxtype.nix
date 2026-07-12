{ pkgs, ... }:
let
  # Offload GPU processing via vulkan
  voxtype = pkgs.callPackage ../packages/voxtype.nix { variant = "vulkan"; };
in
{
  # Push to talk requires access to input group
  users.users.hschne.extraGroups = [ "input" ];

  environment.systemPackages = [ voxtype ];
}
