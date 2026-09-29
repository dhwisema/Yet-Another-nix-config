{ pkgs, lib, ... }:
{

  services.udisks2.enable = true; # external drives
  services.gvfs.enable = true; # virtual fs
  nixpkgs.overlays = [
    (final: prev: {
      nautilus = prev.nautilus.overrideAttrs (nprev: {
        buildInputs =
          nprev.buildInputs
          ++ (with pkgs.gst_all_1; [
            gst-plugins-good
            gst-plugins-bad
          ]);
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    nautilus
    nautilus-open-any-terminal
    libheif
    libheif.out
  ];

}
