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
