{
  pkgs,
  lib,
  ...
}:
{
  networking.firewall.allowedUDPPorts = [ 40000 ];
}
