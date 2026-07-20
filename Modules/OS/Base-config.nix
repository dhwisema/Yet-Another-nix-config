{
  pkgs,
  lib,
  config,
  hostname,
  ...
}:
{
  imports = [
    ./nix-config.nix
    ./users.nix
    ./../hardware/nvidia.nix
    ./../Programs/basepkgs.nix
  ];

  networking = {
    hostName = hostname;
    nftables.enable = true;
    networkmanager.enable = true; # network manager default
  };
  environment.variables = {
    EDITOR = "hx";
  };

  #enable and make fish defaultUserShell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  #set locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  systemd.targets.multi-user.enable = true;
  hardware.enableRedistributableFirmware = true;
  #systemd boot enable and also set latest kernel
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    initrd.systemd.enable = true;
  };

  #services
  services = {
    tuned = {
      # tuned powermanagement
      enable = true;
      settings = {
        dynamic_tuning = true;
      };
    };
    firewalld.enable = true; # firewall goodness
    tailscale.enable = true; # tailscale
    tailscale.openFirewall = true;
  };
  networking.firewall.checkReversePath = "loose";
  system.stateVersion = "26.05";
}
