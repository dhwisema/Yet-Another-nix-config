{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configureation.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages;
  systemd.services."systemd-suspend" = {
    serviceConfig = {
      Environment = ''"SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false"'';
    };
  };
  services.udev.extraRules = ''
    # Royal Kludge RK R65 - Disable joystick/tablet nodes to fix Steam detection
    SUBSYSTEM=="input", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e453", ENV{ID_INPUT_JOYSTICK}="", ENV{ID_INPUT_TABLET}=""
  '';

  boot.blacklistedKernelModules = [ "r8169" ];
  boot.kernelModules = [ "r8125" ];

  systemd.services.ethtool-enp7s0 = {
    description = "Disable Energy Efficient Ethernet on enp7s0";
    wantedBy = [ "network.target" ];
    after = [
      "network.target"
      "sys-subsystem-net-devices-enp7s0.device"
    ];
    bindsTo = [ "sys-subsystem-net-devices-enp7s0.device" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.ethtool} --set-eee enp7s0 eee off";
      RemainAfterExit = true;
    };
  };
}
