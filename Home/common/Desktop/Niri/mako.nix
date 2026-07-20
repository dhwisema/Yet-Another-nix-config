{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.mako = {
    enable = true;
    settings = {
      layer = "overlay";
      anchor = "top-center";
      width = 300; # Notification width
      height = 100; # Notification height
      margin = "10"; # Screen margin (e.g., "10" or "20,50")
      padding = "5"; # Inner padding
      border-size = 2; # Border thickness
      border-radius = 5; # Rounded corners
      default-timeout = 10000; # Timeout in milliseconds (10 seconds)
    };
  };
}
