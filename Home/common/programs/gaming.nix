{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Add an option to enable or disable gaming-related configurations
  # Conditionally apply gaming packages and services if enabled

  home.packages = with pkgs; [
    gamemode
    wine
    steam-run
    steam
    protonup-rs
    r2modman
    prismlauncher
    #Because i need fusion 360
    mokutil
    desktop-file-utils
    lsb-release
    mesa
    p7zip
    cabextract
    samba
    bc
    xrandr
  ];

}
