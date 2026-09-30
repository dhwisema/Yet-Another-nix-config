{ pkgs, lib, ... }:
{
  #contains information for noctalia greeter and shell
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
  };
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.displayManager.noctalia-greeter = {
    enable = true;
  };
}
