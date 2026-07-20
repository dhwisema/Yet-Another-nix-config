{ pkgs, ... }:
{
  home.packages = with pkgs; [
    yazi
    eza
    helix
    lazygit
  ];
}
