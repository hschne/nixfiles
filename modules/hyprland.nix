{ config, pkgs, ... }:
let
  sddmTheme = pkgs.sddm-astronaut.override {
    embeddedTheme = "purple_leaves";
    themeConfig = {
      Font = "SauceCodePro Nerd Font";
      RoundCorners = "0";
      DimBackground = "0.15";

      HeaderTextColor = "#a9b1d6";
      DateTextColor = "#a9b1d6";
      TimeTextColor = "#a9b1d6";
      FormBackgroundColor = "#1a1b26";
      BackgroundColor = "#1a1b26";
      DimBackgroundColor = "#1a1b26";
      LoginFieldBackgroundColor = "#1a1b26";
      PasswordFieldBackgroundColor = "#1a1b26";
      LoginFieldTextColor = "#a9b1d6";
      PasswordFieldTextColor = "#a9b1d6";
      UserIconColor = "#7aa2f7";
      PasswordIconColor = "#bb9af7";
      PlaceholderTextColor = "#565f89";
      WarningColor = "#f7768e";
      LoginButtonTextColor = "#1a1b26";
      LoginButtonBackgroundColor = "#7aa2f7";
      SystemButtonsIconsColor = "#a9b1d6";
      SessionButtonTextColor = "#a9b1d6";
      VirtualKeyboardButtonTextColor = "#a9b1d6";
      DropdownTextColor = "#a9b1d6";
      DropdownSelectedBackgroundColor = "#7aa2f7";
      DropdownBackgroundColor = "#1a1b26";
      HighlightTextColor = "#1a1b26";
      HighlightBackgroundColor = "#bb9af7";
      HighlightBorderColor = "#bb9af7";
      HoverUserIconColor = "#bb9af7";
      HoverPasswordIconColor = "#7aa2f7";
      HoverSystemButtonsIconsColor = "#7aa2f7";
      HoverSessionButtonTextColor = "#7aa2f7";
      HoverVirtualKeyboardButtonTextColor = "#7aa2f7";
    };
  };
in
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
      extraPackages = [ pkgs.kdePackages.qtmultimedia ];
      theme = "sddm-astronaut-theme";
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

    # SDDM theme
    sddmTheme

    # Qt Wayland support
    qt5.qtwayland
    qt6.qtwayland
  ];
}
