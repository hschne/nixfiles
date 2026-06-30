{ pkgs, ... }:
let
  # avx2 = FMA-optimized CPU build. On real hardware with a Vulkan GPU, pass
  # { variant = "vulkan"; } for GPU offload (hardware.graphics is enabled in
  # desktop.nix); its runtime deps stay wrapped inside the package.
  voxtype = pkgs.callPackage ../packages/voxtype.nix { variant = "avx2"; };
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
