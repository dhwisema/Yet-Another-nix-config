{ pkgs, lib, ... }:
{
  #contains information for noctalia greeter and shell
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };
  services.displayManager.noctalia-greeter = {
    enable = true;
  };
}
