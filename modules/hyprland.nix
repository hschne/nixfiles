{ config, pkgs, ... }:
{
  # Hyprland compositor and everything the session launches
  hardware.graphics.enable = true;

  # Hyprland session launched through uwsm.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.xserver.enable = true;
  services.displayManager = {
    defaultSession = "hyprland-uwsm";
    autoLogin = {
      enable = true;
      user = "hschne";
    };
    sddm = {
      enable = true;
      theme = "breeze";
    };
  };

  # Hint Electron/Chromium apps to use Wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Walker's data provider backend.
  systemd.user.services.elephant = {
    description = "Elephant data provider service";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    path = [ config.system.path ];
    serviceConfig = {
      ExecStart = "${pkgs.elephant}/bin/elephant";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  environment.systemPackages = with pkgs; [
    # Terminal, launcher, file manager, notifications, bar
    kitty
    walker
    elephant
    nautilus
    mako
    waybar

    # Hyprland ecosystem
    hypridle
    hyprlock
    hyprpicker
    hyprpaper
    hyprsunset
    hyprcursor

    # Monitors / idle / media
    kanshi
    wdisplays
    swaybg
    swayosd
    brightnessctl
    playerctl
    wlr-randr
    wayfreeze

    # Screenshots / clipboard / images
    grim
    slurp
    satty
    wl-clipboard
    imv
    imagemagick

    # Notifications
    libnotify

    # SDDM breeze theme
    kdePackages.breeze

    # Qt Wayland support
    qt5.qtwayland
    qt6.qtwayland
  ];
}
