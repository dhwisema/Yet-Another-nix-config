{ config, pkgs, ... }:
{
  networking.firewall.allowedUDPPorts = [
    25565
    19132
  ];
  networking.firewall.allowedTCPPorts = [
    25565
    19132
  ]; # PORTS FOR java and bedrock
  #change default security list in oci management to allow above ports
  virtualisation.oci-containers = {
    backend = "podman"; # or "docker" if you prefer

    containers.mc = {
      image = "itzg/minecraft-server:latest";

      # tty = true;
      # stdinOpen = true;

      ports = [
        "25565:25565"
        "19132:19132/udp"
      ];

      environment = {
        RCON_CMDS_STARTUP = ''
          geyser connectiontest 129.213.163.47 19132
        '';
        RCON_CMDS_ON_CONNECT = "";
        RCON_CMDS_LAST_DISCONNECT = "";
        EULA = "TRUE";
        TYPE = "FABRIC";
        PLUGINS = "";
        SEED = "8796151973292232186";
        VANILLATWEAKS_SHARECODE = "Xa3ASF";
        MODRINTH_PROJECTS = ''
          lithium
          carpet
          fabric-api
          ferrite-core
          clumps
          phantom-spawning
          view-distance-fix
          noisiumforked
          chunky
          limitlessenchantments
          geyser
          floodgate
          scalablelux
          datapack:trek
          datapack:geophilic
          datapack:mingen
          datapack:unlock-all-recipes
          datapack:enderman-grief
          dungeons-and-taverns
          dungeons-and-taverns-ancient-city-overhaul
          dungeons-and-taverns-stronghold-overhaul
          dungeons-and-taverns-pillager-outpost-overhaul
          dungeons-and-taverns-swamp-hut-overhaul
          dungeons-and-taverns-woodland-mansion-overhaul
          dungeons-and-taverns-ocean-monument-overhaul
          dungeons-and-taverns-jungle-temple-overhaul
          dungeons-and-taverns-desert-temple-overhaul
          dungeons-and-taverns-nether-fortress-overhaul
        '';

        VIEW_DISTANCE = "16";
        OPS = "Huntingdog5 ";
        EXISTING_OPS_FILE = "SYNCHRONIZE";
        ENABLE_WHITELIST = "true";
        WHITELIST = ''
                  Huntingdog5  
                  DancingCat524
                  ThinkingWithTime
          				manaexons
          				hamburgerchicken
          				schooner42
          				MikeyNCheese
          		'';
        VERSION = "1.21.11";
        MEMORY = "16384M";
        TZ = "America/New_York";
        MODRINTH_DOWNLOAD_DEPENDENCIES = "required";
        MODRINTH_ALLOWED_VERSION_TYPE = "alpha";
      };
      extraOptions = [
        "--interactive"
        "--tty"
      ];
      volumes = [
        "/home/irrelevancy/mc/data:/data"
      ];
    };
  };
}
