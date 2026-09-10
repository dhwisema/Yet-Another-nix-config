{
  config,
  lib,
  pkgs,
  hostname,
  role,
  ...
}:
{
  imports =
    if hostname == "Pumat" then
      [
        #./Modules/Containers/CWA.nix
        ./Modules/Containers/Jellyfin.nix
        ./Modules/Containers/ARR.nix
      ]
    else if hostname == "Yasha" then
      [ ./Modules/Containers/CWA.nix
        ./Modules/Containers/Miniflux.nix ]
    else if hostname == "Jester" then
      [
        ./Modules/OS/vfio.nix
              ]
    else if role == "Desktop" then
      [ ./Modules/OS/Networking.nix]
    else [];
}
