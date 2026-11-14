{
  pkgs,
  lib,
  config,
  hostname,
  username,
  options,
  inputs,
  ...
}:
{
  imports = [
    ./Base-config.nix
    ./../Desktop/Desktop.nix
    ./../Programs/Idevice.nix
    ./Networking.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.stylix.nixosModules.stylix
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    ];
  environment.etc."nix/nixpkgs-config.nix".text = "{ allowUnfree = true; }";
  #because i hate life and nixos doesnt have pyside 6 working correctly yay
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.bluetooth.enable = true;
  services.flatpak = {
    enable = true;
    packages = [
      "com.usebottles.bottles"
      "com.github.tchx84.Flatseal"
    ];
  };
  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;
  environment.systemPackages = with pkgs; [
    distrobox
    distrobox-tui
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.fira-code
  ];

  programs.nix-ld = {
    enable = true;
    libraries =
      options.programs.nix-ld.libraries.default
      ++ (with pkgs; [
        glib # libglib-2.0.so.0
        libGL
      ]);
  };
  users.users.${username}.extraGroups = [
    "video"
    "audio"
    "render"
  ];

  services.fwupd.enable = true;
  services.libinput.enable = true;
  zramSwap.enable = true;
}
