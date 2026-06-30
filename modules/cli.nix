{ pkgs, ... }:
{
  # Extra command-line tools from the workstation setup that aren't part of
  # the shared base.nix baseline.
  environment.systemPackages = with pkgs; [
    glab      # GitLab CLI
    navi      # interactive cheatsheets
    atuin     # shell history
    lf        # terminal file manager
    walk      # terminal file browser
    w3m       # terminal web browser
    fx        # terminal JSON viewer
    silicon   # source-code screenshots
    p7zip     # 7z archives
  ];
}
