# VirtualBox test-VM overrides.
#
# Remove this import from ./default.nix when deploying rocinante to real
# hardware (together with regenerating hardware-configuration.nix). Nothing
# here is wanted on the laptop.
{ ... }:
{
  # VirtualBox exposes no GPU acceleration usable by wlroots, so Hyprland's
  # EGL init crashes. Force Mesa's llvmpipe software renderer instead.
  environment.sessionVariables = {
    LIBGL_ALWAYS_SOFTWARE = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
