{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-CT1000T500SSD8_2407470C19C6";

        content = {
          type = "gpt";

          partitions = {
            boot = {
              size = "1G";
              type = "EF00";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              size = "100%";

              content = {
                type = "btrfs";

                extraArgs = [
                  "-f"
                  "-L"
                  "nixos"
                ];

                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=root"
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=home"
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  "/swap" = {
                    mountpoint = "/swap";

                    mountOptions = [
                      "subvol=swap"
                      "noatime"
                      "ssd"
                    ];

                    swap.swapfile.size = "32G";
                  };
                };
              };
            };
          };
        };
      };

      sata-one = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANZ0R402138X";

        content = {
          type = "gpt";

          partitions = {
            data = {
              size = "100%";
            };
          };
        };
      };

      sata-two = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SK_hynix_SC313_SATA_512GB_MJ88N525610308O3E";

        content = {
          type = "gpt";

          partitions = {
            data = {
              size = "100%";

              content = {
                type = "btrfs";

                extraArgs = [
                  "-f"
                  "-L"
                  "data"
                  "-m"
                  "raid1"
                  "-d"
                  "raid1"
                  "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S62ANZ0R402138X"

                ];

                mountpoint = "/data";

                mountOptions = [
                  "compress=zstd:3"
                  "noatime"
                  "discard=async"
                ];
              };
            };
          };
        };
      };
    };
  };
}
