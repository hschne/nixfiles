{ pkgs, ... }:
let
  voxtype = pkgs.callPackage ../packages/voxtype.nix { };
in
{
  # GUI applications that need a desktop session.
  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # Browsers
    chromium

    # Office / documents / reading
    libreoffice-still
    calibre
    xournalpp
    zathura
    speedcrunch

    # Media
    vlc
    spotify
    spicetify-cli

    # Graphics / video
    gimp
    inkscape
    kdePackages.kdenlive

    # Communication
    signal-desktop

    # Files / transfer / capture
    filezilla
    gpu-screen-recorder

    # Push-to-talk voice-to-text (prebuilt AVX2 binary; see packages/voxtype.nix).
    voxtype
  ];
}
