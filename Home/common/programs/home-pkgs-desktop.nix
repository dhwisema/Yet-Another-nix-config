{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [ ./glide.nix ];
  home.packages = with pkgs; [
    onlyoffice-desktopeditors
    smplayer
    foliate
    ghostty
    nixfmt
    nixfmt-tree
    kicad
    nil
    signal-desktop
    element-desktop
    nixd
    webcord-vencord
    age
    sops
    halloy
  ];
  # xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";
  programs.zellij = {
    enable = true;
    settings = {
      copy_command = "wl-copy";
    };
  };
}
