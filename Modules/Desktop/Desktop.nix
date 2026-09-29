{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./themeing/stylix.nix
    ./Niri/niri-base.nix
    #./Gnome/default.nix
  ];
}
