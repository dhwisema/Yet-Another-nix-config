{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Add an option to enable or disable iphone pairing for ethernet/file transfer
  #

  #

  environment.systemPackages = with pkgs; [
    usbmuxd
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'
  ];
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };
}
# Mounting
# Mounting the device via iFuse is possible with the following commands
# $ mkdir /tmp/iphone
# $ ifuse /tmp/iphone
# Tethering
# Tethering on iOS is possible via Wifi hotspot, Bluetooth or USB. In order to enable USB tethering, first enable tethering in the iOS networking settings. After that run following command
# $ idevicepair pair
# Confirm pairing by accepting the connection on your iOS device. After that an ethernet device will appear in your network device list.
