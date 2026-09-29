{
  pkgs,
  config,
  lib,
  ...
}:
{
  sops.secrets."miniflux_admin_env"={
    sopsFile = ../../secrets/miniflux.env;
    format = "dotenv";
  };
  
  services.miniflux.enable = true;
  services.miniflux.adminCredentialsFile = config.sops.secrets."miniflux_admin_env".path;
}
