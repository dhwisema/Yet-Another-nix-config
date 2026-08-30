{
  lib,
  config,
  pkgs,...
}:
{
  networking = {
    networkmanager.enable = lib.mkForce false;
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
