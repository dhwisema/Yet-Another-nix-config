{ pkgs, config, ... }:
{
  #move thos
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    cacheDir = "/data/cache/jellyfin";
    logDir = "/data/log/jellyfin";
    configDir = "/data/config/jellyfin";
  };

  systemd.services.jellyfin.environment = {
    LIBVA_DRIVER_NAME = "iHD";
  };

}
