{
  pkgs,
  lib,
  ...
}:
{
  #uhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
  services.fail2ban.enable = true;
  #tailscale peer relay
  networking.firewall.allowedUDPPorts = [ 40000 ];
}
