{ pkgs, config, ... }: {
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  gtk = {
    enable = true;
    theme = {
      name = "everforest";
      package = pkgs.everforest-gtk-theme;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "everforest";
      package = pkgs.everforest-cursors;
    };
  };
}
