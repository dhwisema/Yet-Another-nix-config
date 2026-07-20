{
  pkgs,
  config,
  lib,
  ...
}:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Spoof Apple Vendor ID for advanced AirPods features
        DeviceID = "bluetooth:004C:0000:0000";
      };
    };
  };
  environment.systemPackages = with pkgs; [ librepods ];
}
