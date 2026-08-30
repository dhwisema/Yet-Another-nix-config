{
  lib,
  config,
  pkgs,...
}:
{
  networking = {
    networking.networkmanager.enable = lib.mkforce false;
    useNetworkd = true;
    useDHCP = true;
    wireless.iwd = {
      enable = true;
      Network = {
        EnableIPv6 = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };
  environment.systemPackages = with pkgs; [ impala ];
}
