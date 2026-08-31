{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking = {
    networkmanager.enable = lib.mkForce false;
    useNetworkd = true;
    useDHCP = true;
    wireless.iwd = {
      enable = true;
    };
  };
  environment.systemPackages = with pkgs; [ impala ];
  boot.kernelModules = ["pkcs8_key_parser"];
}
