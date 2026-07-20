{
  pkgs,
  lib,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  systemd.services."systemd-suspend" = {
    serviceConfig = {
      Environment = ''"SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false"'';
    };
  };
  services.udev.extraRules = ''
    # Royal Kludge RK R65 - Disable joystick/tablet nodes to fix Steam detection
    SUBSYSTEM=="input", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e453", ENV{ID_INPUT_JOYSTICK}="", ENV{ID_INPUT_TABLET}=""
  '';

}
