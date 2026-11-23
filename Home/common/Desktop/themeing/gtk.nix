{ pkgs, config, ... }: {
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.everforest-cursors;
    name = "everforest-cursors";
  };
  gtk = {
    enable = true;
    theme = {
      name = "Everforest-dark";
      package = pkgs.everforest-gtk-theme;
    };
    gtk4 = {
      name = "Everforest-dark";
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
