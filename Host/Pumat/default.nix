{
  config,
  lib,
  pkgs,
  ...
}:
{

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
  imports = [
    ./Modules/Containers/Jellyfin.nix
    ./Modules/Containers/ARR.nix
  ];
}
