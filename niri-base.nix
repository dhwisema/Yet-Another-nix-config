{ pkgs, lib, ... }: {
  imports = [
    ./nautilus.nix
    ./noctalia-base.nix
  ]; # required by gnome

  programs.niri.enable = true; # acutally enable niri
  programs.dconf.enable = true; # allows dconf config
  #reccommended portals for niri
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome # requires nautilus
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
    xwayland-satellite # for x11 window support
    pavucontrol # audio fuckery
    bluetuith # bluetooth stuff
    awww # good wallpaper daemon
    wl-clipboard # terminal clipboard i think
  ];

  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service

  hardware.brillo.enable = true; # what i use for brightness

}
