{ pkgs, ... }:
{
  # Extra command-line tools from the workstation setup that aren't part of
  # the shared base.nix baseline.
  environment.systemPackages = with pkgs; [
    yazi      # terminal file manager
    fx        # terminal JSON viewer
    silicon   # source-code screenshots
    p7zip     # 7z archives
  ];
}
