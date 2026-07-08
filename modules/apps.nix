{ config, pkgs, ... }:
let
  # vulkan = GPU offload on the Radeon 760M (hardware.graphics is enabled in
  # desktop.nix); its runtime deps stay wrapped inside the package. Use
  # { variant = "avx2"; } for a CPU-only / VM build.
  voxtype = pkgs.callPackage ../packages/voxtype.nix { variant = "vulkan"; };
in
{
  # GUI applications that need a desktop session.
  nixpkgs.config.allowUnfree = true;

  # OBS with virtual camera (v4l2loopback). Lets Meet read a "camera" fed by
  # OBS's screen capture, which persists its portal selection via restore
  # tokens (no repeated share pickers). v4l2loopback is configured manually
  # instead of via programs.obs-studio.enableVirtualCamera because that
  # hardcodes video_nr=1, which collides with the laptop webcam's /dev/video1.
  programs.obs-studio.enable = true;
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';

  programs.firefox = {
    enable = true;
    # VA-API hardware video decoding (radeonsi). Note: Firefox cannot
    # hardware-encode WebRTC on Linux (bugzilla 1658900), so Meet
    # screensharing always software-encodes there; use Chromium for calls.
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.navigator.mediadatadecoder_vpx_enabled" = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Browsers
    #
    # AcceleratedVideoEncoder enables VA-API hardware video encoding (H.264 +
    # AV1 on the Radeon 760M), which Meet/WebRTC screensharing uses instead of
    # burning CPU on libvpx/libaom. WaylandWindowDecorations must be repeated
    # here because a later --enable-features overrides the one added by the
    # NIXOS_OZONE_WL wrapper.
    (chromium.override {
      commandLineArgs = [
        "--enable-features=AcceleratedVideoEncoder,WaylandWindowDecorations"
      ];
    })

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
