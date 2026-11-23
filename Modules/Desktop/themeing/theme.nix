{ pkgs, username, ... }:
# let
#   gtkSettings = pkgs.writeText "gtk-settings.ini" ''
#     [Settings]
#     gtk-cursor-theme-name=everforest-cursors
#     gtk-cursor-theme-size=24
#     gtk-font-name=Fira Sans 11
#     gtk-icon-theme-name=Adwaita
#     gtk-theme-name=Adwaita
#   '';
# in
{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    everforest-cursors
    adw-gtk3
  ];

  # allows configuring desktop things/gtk
  programs.dconf.enable = true;

  # systemd.tmpfiles.settings."10-gtk" = {
  #   "/home/${username}/.config/gtk-3.0/settings.ini"."L+".argument = toString gtkSettings;
  #   "/home/${username}/.config/gtk-4.0/settings.ini"."L+".argument = toString gtkSettings;
  # };
}
