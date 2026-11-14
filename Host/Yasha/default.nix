{ config, lib, ... }:
{

  imports = [
    ./Modules/Containers/CWA.nix
    ./Modules/Containers/Miniflux.nix
  ];
  fileSystems = {
    "/".options = [
      "compress=zstd"
      "noatime"
    ];
    "/home".options = [
      "compress=zstd"
      "noatime"
    ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
    "/data".options = [
      "compress=zstd"
      "noatime"
    ];
  }; # girl what the fuck

  # swapDevices = [ { device = "/swap/swapfile"; } ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  services.tailscale.useRoutingFeatures = "both";
  zramSwap.enable = true;

}
