{
  pkgs,
  config,
  lib,
  ...
}:
{
  sops.secrets."miniflux_admin_env"={
    sopsFile = ../../secrets/miniflux.yaml;
    key = "";
  };
  
  services.miniflux.enable = true;
  services.miniflux.adminCredentialsFile = config.sops.secrets."miniflux_admin_env".path;
}
