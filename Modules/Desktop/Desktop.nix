{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./Niri/niri-base.nix
    #./Gnome/default.nix
  ];
}
