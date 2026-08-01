{
  nixpkgs,
  hostname,
  lib,
  ...
}:
{
  virtualisation.oci-containers.containers.calibre-Web-Automate = {
    pull = "newer";
    image = "ghcr.io/new-usemame/calibre-web-nextgen:latest";
   
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "America/New_York";
      HARDCOVER_TOKEN = "";
      CWA_PORT_OVERRIDE = "8083";
      NETWORK_SHARE_MODE = "false";
    };
    volumes = [
      "/home/irrelevancy/CWA/config:/config"
      "/home/irrelevancy/ingest:/cwa-book-ingest"
      "/home/irrelevancy/CWA/library:/calibre-library"
    ];
    ports = [ "8083:8083" ];
  };
}
