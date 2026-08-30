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
      Settings = {
        AutoConnect = true;
      };
    };
  };
  environment.systemPackages = with pkgs; [ impala ];
}
