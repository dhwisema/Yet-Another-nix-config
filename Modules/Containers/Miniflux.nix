{
  pkgs,
  config,
  lib,
  ...
}:
{
  sops.secrets."miniflux_admin_env"={
    sopsFile = ./secrets/miniflux.yaml;
    format = "dotenv";
    owner = config.services.miniflux.user;
  };
  
  services.miniflux.enable = true;
  services.miniflux.adminCredentialsFile = config.sops.secrets."miniflux_admin_env".path;
}
