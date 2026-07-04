{ pkgs, ... }:
{
  # Hyprland (Wayland) session, launched through uwsm.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # SDDM with the X11 greeter (reliable under VirtualBox); the session
  # itself is Wayland/Hyprland.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;

  # Hint Electron/Chromium apps to use Wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # GPU drivers / Vulkan ICD (RADV for AMD). Needed for accelerated Hyprland
  # and the Vulkan voxtype variant on real hardware; harmless in the VM, which
  # is forced to software rendering anyway.
  hardware.graphics.enable = true;

  # Desktop portals for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Auth dialogs (the dotfiles' exec-once path is Arch-specific; run the
  # agent declaratively so polkit prompts work regardless). Wheel already has
  # passwordless sudo in base.nix; keep desktop polkit behavior consistent so
  # local admin actions do not repeatedly ask for the root password.
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
  # Elephant: data-provider backend daemon that walker queries. Walker is
  # autostarted by the dotfiles; elephant must be running for it to return
  # results (providers: desktopapplications, websearch, menus, files, symbols,
  # clipboard, providerlist - all bundled in the package).
  systemd.user.services.elephant = {
    description = "Elephant data provider service (walker backend)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    # clipboard provider shells out to wl-paste/wl-copy.
    path = [ pkgs.wl-clipboard ];
    serviceConfig = {
      ExecStart = "${pkgs.elephant}/bin/elephant";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # GTK app settings backend and nautilus mounting support.
  programs.dconf.enable = true;
  services.gvfs.enable = true;

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
    # Terminal, launcher (+ elephant backend), file manager, notifications, bar
    kitty
    walker
    elephant
    nautilus
    mako
    waybar

    # Hyprland ecosystem tools
    hypridle
    hyprlock
    hyprpicker
    hyprpaper
    hyprsunset
    hyprcursor

    # Session helpers / monitor + idle + media
    kanshi
    swaybg
    swayosd
    brightnessctl
    playerctl
    wlr-randr
    wayfreeze

    # Screenshots / clipboard / image viewer / image tooling
    grim
    slurp
    satty
    wl-clipboard
    imv
    imagemagick

    # Notifications + auth + theming
    libnotify
    polkit_gnome
    arc-theme
    papirus-icon-theme

    # Qt Wayland support
    qt5.qtwayland
    qt6.qtwayland
  ];
}
