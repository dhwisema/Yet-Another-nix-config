{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };
  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  # Enable container name DNS for all Podman networks.
  networking.firewall.interfaces =
    let
      matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
    in
    {
      "${matchAll}".allowedUDPPorts = [ 53 ];
    };

  virtualisation.oci-containers.backend = "podman";

  imports = [
    ./calibre-web-automated.nix
  ];
}
