{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    gamemode
    wine
    steam-run
    steam
    protonup-rs
    r2modman
    prismlauncher
    pciutils
    python3
    wine
    heroic
    
  ];

}
