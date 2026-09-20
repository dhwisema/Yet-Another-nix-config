{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.groups.mediashare = {
    gid = 1001;
    members = [
      "irrelevancy"
      "jellyfin"
      "arr"
    ];
  };
  users.users.arr = {
    uid = 1001;
    isSystemUser = true;
    group = "mediashare";
  };
  virtualisation.oci-containers.containers.radarr = {
    environment = {
      PUID = "1001";
      PGID = "1001";
      WEBUI_PORTS = "7878/tcp";
    };
    hostname = "radarr.internal";
    image = "ghcr.io/hotio/radarr:latest";
    ports = [ "7878:7878" ];
    extraOptions = [ "--pull=newer" ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/data/appdata/radarr:/config"
      "/data/jellyarr:/data"
    ];
  };
  virtualisation.oci-containers.containers.sonarr = {
    environment = {
      PUID = "1001";
      PGID = "1001";
      WEBUI_PORTS = "8989/tcp";
    };
    hostname = "sonarr.internal";
    image = "ghcr.io/hotio/sonarr:latest";
    ports = [ "8989:8989" ];

    extraOptions = [ "--pull=newer" ];

    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/data/appdata/sonarr:/config"
      "/data/jellyarr:/data"
    ];
  };
  virtualisation.oci-containers.containers.bazarr = {

    environment = {
      PUID = "1001";
      PGID = "1001";
      WEBUI_PORTS = "6767/tcp";
    };
    hostname = "bazarr.internal";
    image = "ghcr.io/hotio/bazarr:latest";
    ports = [ "6767:6767" ];

    extraOptions = [ "--pull=newer" ];

    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/data/appdata/bazarr:/config"
      "/data/jellyarr:/data"
    ];
  };
  virtualisation.oci-containers.containers.sabnzbd = {
    environment = {
      PUID = "1001";
      PGID = "1001";
      UMASk = "002";
      TZ = "America/Newyork";
      WEBUI_PORTS = "8080/tcp";
    };
    hostname = "sabnzbd.internal";
    image = "ghcr.io/hotio/sabnzbd";
    ports = [
      "9090:9090"
      "8080:8080"
    ];
    extraOptions = [ "--pull=newer" ];
    volumes = [
      "/data/jellyarr/usenet:/data/usenet:rw"
      "/data/appdata/sabnzbd:/config"
      "/etc/localtime:/etc/localtime:ro"
    ];
  };
  virtualisation.oci-containers.containers.qbittorrent = {
    environment = {
      PUID = "1001";
      PGID = "1001";
      UMASK = "002";
      WEBUI_PORTS = "8081/tcp";
      LIBTORRENT = "v1";
      VPN_ENABLED = "true";
      VPN_CONF = "wg0";
      VPN_PROVIDER = "proton";
      VPN_LAN_NETWORK = "192.168.1.0/24";
      VPN_LAN_LEAK_ENABLED = "false";
      VPN_AUTO_PORT_FORWARD = "true";
      VPN_HEALTHCHECK_ENABLED = "false";
      PRIVOXY_ENABLED = "false";
      UNBOUND_ENABLED = "false";
    };
    capabilities = {
      NET_ADMIN = true;
    };

    hostname = "qbittorrent";
    image = "ghcr.io/hotio/qbittorrent:latest";
    ports = [ "8081:8081" ];
    extraOptions = [ "--pull=newer" ];

    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/data/appdata/qbittorrent:/config"
      "/data/jellyarr/torrents:/data/torrent:rw"
    ];

  };

}
