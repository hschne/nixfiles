{ ... }:
{
  # Baseline every host runs: foundation, CLI environment, build toolchain,
  # connectivity, and file sync.
  imports = [
    ../modules/base.nix
    ../modules/cli.nix
    ../modules/dev.nix
    ../modules/networking.nix
    ../modules/syncthing.nix
  ];
}
