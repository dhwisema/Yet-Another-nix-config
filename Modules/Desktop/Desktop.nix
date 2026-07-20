{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./themeing/stylix.nix
    ./Niri/niri.nix
    #./Gnome/default.nix
    ./Airpods-fix.nix
  ];
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
