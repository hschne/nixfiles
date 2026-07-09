{ pkgs, ... }:
{
  # PipeWire audio stack (replaces PulseAudio).
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    # Keep the pinned BT headset profile; don't auto-revert to mic-less A2DP.
    wireplumber.extraConfig."51-disable-bt-autoswitch" = {
      "wireplumber.settings"."bluetooth.autoswitch-to-headset-profile" = false;
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    easyeffects
    calf
    lsp-plugins
    mda_lv2
    zam-plugins
  ];
}
