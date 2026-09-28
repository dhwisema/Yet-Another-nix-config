{
  #only dealing with packages to install
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.dconf.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      niri = {
        default = [
          "gtk"
          "gnome"
        ];
      };
    };
  };
  environment.systemPackages = with pkgs; [
    sway-contrib.grimshot
    xwayland-satellite
    pavucontrol
    waybar
    adwaita-icon-theme-legacy
    adwaita-icon-theme
    bluetuith
    gnome-keyring
    awww
    nautilus
    nautilus-open-any-terminal
    wl-clipboard
    cachix
  ];
  services.gvfs.enable = true;

  hardware.brillo.enable = true;
  environment.pathsToLink = [ "share/thumbnailers" ];

  programs.niri.enable = true;

  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
    lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
      [
        pkgs.gst_all_1.gst-plugins-good
        pkgs.gst_all_1.gst-plugins-bad
        pkgs.gst_all_1.gst-plugins-ugly
        pkgs.gst_all_1.gst-libav
      ];

  services.displayManager.noctalia-greeter = {
    enable = true;
    
  };
}
