{
  description = "combined nixos config for servers and dekstops";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      # declarative disk management
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    stylix.url = "github:danth/stylix";
    #niri.url = "github:sodiboo/niri-flake";
    # updated niri flake
    niri.url = "github:epireyn/niri-flake";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waveforms.url = "github:liff/waveforms-flake";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comin = {
      url = "github:Aehmlo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    glide-browser = {
      url = "github:glide-browser/glide.nix";
      # optionally: follow your flake's inputs
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs =
    inputs:
    with inputs; # weird syntax thing.... i think its neat apparantly this would work but,,, 2026 01 06 -> i fear i understand that this way causes me pain
    let
      username = "irrelevancy";
      mkNixosConfiguration =
        {
          system ? "x86_64-linux",
          role ? "server",
          nvidia ? false,
          disko-use ? true,
          hostname,
          modules,
        }@args-os:
        let
          defaultconf =
            if role == "server" then
              [
                ./Modules/OS/Base-config.nix
                comin.nixosModules.comin
                ./Modules/OS/comin.nix
              ]
            else
              [
                ./Modules/OS/desktop-config.nix
                nix-flatpak.nixosModules.nix-flatpak
                stylix.nixosModules.stylix
                niri.nixosModules.niri
                # waveforms.nixosModule
                # ({ users.users.${username}.extraGroups = [ "plugdev" ]; })
                nixos-hardware.nixosModules.common-cpu-amd # sets scheduling things for kernel
                nixos-hardware.nixosModules.common-pc-ssd # ssd trim
                noctalia-greeter.nixosModules.default
              ];

          diskopath = ./. + "/Host/${hostname}/disk-config.nix";
          hwconf = ./. + "/Host/${hostname}/hardware-configuration.nix";
          diskoconf =
            if disko-use == true then
              [
                disko.nixosModules.disko
                diskopath
              ]
            else
              [ ];
          default-hm = if role == "server" then [ ./Home/server.nix ] else [ ./Home/desktop.nix ];

          specialArgs = {

            inherit
              inputs
              username
              hostname
              role
              nvidia
              ;
          }
          // args-os;
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            # (specialArgs)
            home-manager.nixosModules.home-manager
            {

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { inherit inputs username; };

              home-manager.users.${username} = {
                imports = default-hm;
              };
            }
            hwconf
          ]
          ++ modules
          ++ defaultconf
          ++ diskoconf;
        };
    in
    {
      nixosConfigurations = {
        Jester = mkNixosConfiguration {
          hostname = "Jester";
          role = "Desktop";
          modules = [
            ./Host/Jester/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-z # i fear lenovo did not cook with this one
            lanzaboote.nixosModules.lanzaboote
            ./Modules/OS/SecureBoot.nix
          ];
        }; # thinkpad z16
        Beau = mkNixosConfiguration {
          hostname = "Beau";
          role = "Desktop";
          disko-use = false;
          nvidia = true;
          modules = [ ./Host/Beau/configuration.nix ];
        }; # 7800x3d gaming pc
        Stacy-Fakename = mkNixosConfiguration {
          hostname = "Stacy-Fakename";
          system = "aarch64-linux";
          modules = [
            #./Modules/Containers/mc.nix
            ./Host/Stacy-Fakename/configuration.nix
          ];
        }; # oracle cloud box
        Pumat = mkNixosConfiguration {
          hostname = "Pumat";
          modules = [
            ./default.nix
            ./Host/Pumat
          ];
        }; # dell optiplex
        Yasha = mkNixosConfiguration {
          disko-use = false;
          hostname = "Yasha";
          modules = [ ./Host/Yasha ];
        }; # lenovo mq90
      };
    };
}
