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
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets."miniflux_admin_env".path;
    config.LISTEN_ADDR = "0.0.0.0:8080";
  };
}
