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
  ];

}
