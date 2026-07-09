{ config, pkgs, ... }:
{
  # GUI applications; needs desktop.nix.

  # OBS virtual camera. v4l2loopback is configured manually because
  # programs.obs-studio.enableVirtualCamera hardcodes video_nr=1, which
  # collides with the laptop webcam.
  programs.obs-studio.enable = true;
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';

  programs.firefox = {
    enable = true;
    # VA-API decoding. Firefox can't hardware-encode WebRTC on Linux
    # (bugzilla 1658900); use Chromium for calls.
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.navigator.mediadatadecoder_vpx_enabled" = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # AcceleratedVideoEncoder: VA-API encoding for WebRTC screensharing.
    # WaylandWindowDecorations must be repeated because this flag overrides
    # the one from the NIXOS_OZONE_WL wrapper.
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
    discord

    # Files / transfer / capture
    filezilla
    wl-screenrec

    # Push-to-talk voice-to-text; vulkan = GPU offload on the Radeon 760M.
    (callPackage ../packages/voxtype.nix { variant = "vulkan"; })
  ];
}
