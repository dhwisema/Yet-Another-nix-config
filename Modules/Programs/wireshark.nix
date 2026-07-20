{
  pkgs,
  config,
  lib,
  username,
  ...
}:
{
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  users.users.${username}.extraGroups = [ "wireshark" ];

  services.udev = {
    extraRules = ''
      SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
    '';
  };

}
