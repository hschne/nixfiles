{ pkgs, ... }:
let
  # vulkan = GPU offload on the Radeon 760M (hardware.graphics is enabled in
  # desktop.nix); its runtime deps stay wrapped inside the package. Use
  # { variant = "avx2"; } for a CPU-only / VM build.
  voxtype = pkgs.callPackage ../packages/voxtype.nix { variant = "vulkan"; };
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
    wl-screenrec

    # Push-to-talk voice-to-text (see packages/voxtype.nix).
    voxtype
  ];
}
