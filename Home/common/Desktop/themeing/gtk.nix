{ pkgs, config, ... }: {
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
