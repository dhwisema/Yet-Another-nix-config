{
  nixpkgs,
  hostname,
  lib,
  ...
}:
{
  virtualisation.oci-containers.containers.calibre-Web-Automate = {
    pull = "newer";
    image = "crocodilestick/calibre-web-automated:latest";

    environment = {
      PUID = "1020";
      PGID = "1020";
      TZ = "America/New_York";
      HARDCOVER_TOKEN = "";
      CWA_PORT_OVERRIDE = "8083";
      NETWORK_SHARE_MODE = "false";
    };
    volumes = [
      "/data/CWA/config:/config"
      "/data/CWA/ingest:/cwa-book-ingest"
      "/data/CWA/library:/calibre-library"
    ];
    ports = [ "8083:8083" ];
  };
}
