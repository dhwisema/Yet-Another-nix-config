{
  config,
  lib,
  stylix,
  pkgs,
  ...
}:
{
  stylix.enableReleaseChecks = false;
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
  stylix.polarity = "dark";
  stylix.autoEnable = true;
  stylix.targets.qt.platform = lib.mkForce "qtct";
  stylix.cursor = {
    name = "BreezeX-RosePine-Linux";
    package = pkgs.rose-pine-cursor;
    size = 18;
  };

}
