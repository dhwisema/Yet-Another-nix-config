{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      launch_apps_as_systemd_services = true;
      # This may also be a string or path to a .toml file.
      # theme = {
      #   mode = "dark";
      #   source = "builtin";
      #   builtin = "Catppuccin";
      # };

      wallpaper = {
        enabled = false;
      };
    };
  };
}
