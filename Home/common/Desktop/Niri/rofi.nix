{
  config,
  pkgs,
  inputs,
  ...
}:
{

  programs.rofi = {
    enable = true;
    plugins = with pkgs; [

      rofi-power-menu
    ];
    extraConfig = {
      modi = "window,drun,combi,power-menu:${pkgs.rofi-power-menu}/bin/rofi-power-menu";
    };
  };
  home.packages = with pkgs; [
    rofi-bluetooth
  ];
}
