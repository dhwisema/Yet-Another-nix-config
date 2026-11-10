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
    protonup-ng
    pciutils
    python3
    wine
    heroic
    nanoboyadvance
    skyemu
    melonds
  ];

}
