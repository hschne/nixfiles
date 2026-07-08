{ config, pkgs, ... }:
{
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

  # GPU drivers / Vulkan ICD (RADV).
  hardware.graphics.enable = true;

  # Portals for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # No polkit password prompts for wheel (matches passwordless sudo).
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.local && subject.active && subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };

  systemd.user.services.elephant = {
    description = "Elephant data provider service";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    # Providers shell out to desktop tools; give them the full system profile.
    path = [ config.system.path ];
    serviceConfig = {
      ExecStart = "${pkgs.elephant}/bin/elephant";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Secret Service provider for desktop apps and pass-cli.
  services.gnome.gnome-keyring.enable = true;

  # GTK settings backend and nautilus mounting support.
  programs.dconf.enable = true;
  services.gvfs.enable = true;

  # Papirus/Adwaita icons are SVG; without librsvg as a pixbuf loader GTK
  # renders missing-image placeholders.
  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # Papirus (not Papirus-Dark) — the dark variant lacks some emblems.
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Arc-Dark
    gtk-icon-theme-name=Papirus
    gtk-application-prefer-dark-theme=1
  '';
  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Arc-Dark
    gtk-icon-theme-name=Papirus
    gtk-application-prefer-dark-theme=1
  '';

  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    material-icons
    material-design-icons
    (callPackage ../packages/lobe-icons-font.nix { })
  ];

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

    # Notifications / auth / theming
    libnotify
    polkit_gnome
    arc-theme
    papirus-icon-theme
    adwaita-icon-theme
    hicolor-icon-theme
    kdePackages.breeze

    # Qt Wayland support
    qt5.qtwayland
    qt6.qtwayland
  ];
}
