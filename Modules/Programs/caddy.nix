{
  pkgs,
  lib,
  role,
  config,
  lib,
  ...
}:
{

  services.caddy =
    if role == "server " then
      {
        enable = true;
        extraConfig = "
       machine-name.domain-alias.ts.net
       root * /var/www
       file_server
     ";

      }
    else
      { enable = false; };

}
