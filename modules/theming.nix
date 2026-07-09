{ pkgs, ... }:
{
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
    arc-theme
    papirus-icon-theme
    adwaita-icon-theme
    hicolor-icon-theme
  ];
}
