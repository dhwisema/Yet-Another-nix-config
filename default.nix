{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
{
  imports =
    if hostname == "Pumat" then
      [
        ./Modules/Containers/CWA.nix
        ./Modules/Containers/Jellyfin.nix
        ./Modules/Containers/ARR.nix
      ]
    else if hostname == "Stacy-Fakename" then
      [ ./Modules/Containers/CWA.nix ]
    else
      [ ];
}
