{
  pkgs,
  lib,
  config,
  hostname,
  inputs,
  ...
}:
let
  colors = (import ../../colors.nix).colors;
in
{
  imports = [
    ./nix-config.nix
    ./users.nix
    ./../Programs/basepkgs.nix
    ../../Home/hm.nix
    inputs.sops-nix.nixosModules.sops
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];
  sops.defaultSopsFile = ./secrets/secret.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = [
    "/home/irrelevancy/.ssh/id_ed25519"
    "/etc/ssh/ssh_host_ed25519_key"
  ];
  #end sops
  networking = {
    hostName = hostname;
    nftables.enable = true;
    networkmanager.enable = true; # network manager default
  };
  environment.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SYSTEMD_TINT_BACKGROUND = "false";
    SYSTEMD_RUN_SHELL_PROMPT_PREFIX = "";
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
  };
  environment.systemPackages = with pkgs; [
    polkit_gnome
  ];
  #remove sudo cause a certain eldritch space entity told me to do so.
  security = {
    run0 = {
      enable = true;
      sudo-shim.enable = true;
    };
    sudo.enable = false;
    wrappers = {
      # mount/umount are only relevant for non-root users when an fstab entry
      # has user/group information
      mount.enable = false;
      umount.enable = false;

      # redundant with run0 for privilege escalation
      newgrp.enable = false;
      sg.enable = false;
      su.enable = false;
    };
  };
  #services
  services = {
    bootvine.enable = true;
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
  networking.firewall.checkReversePath = "loose"; # tailscale something
  system.stateVersion = "26.05";

  #limit journal size
  services.journald.settings.Journal = {
    SystemMaxUse = "100M";
    RuntimeMaxUse = "50M";
    SystemMaxFileSize = "50M";
  };
  #shell scripts begone
  system.nixos-init.enable = true;
  #run shell check during build to prevent bad shell
  # "bad shell looks like? <-irrelevancy " " shrug." <- eldritch space creature
  systemd.enableStrictShellChecks = lib.mkDefault true;
  console.colors = [
    "${colors.base00}"
    "${colors.base01}"
    "${colors.base02}"
    "${colors.base03}"
    "${colors.base04}"
    "${colors.base05}"
    "${colors.base06}"
    "${colors.base07}"
    "${colors.base08}"
    "${colors.base09}"
    "${colors.base0A}"
    "${colors.base0B}"
    "${colors.base0C}"
    "${colors.base0D}"
    "${colors.base0E}"
    "${colors.base0F}"
  ];
}
