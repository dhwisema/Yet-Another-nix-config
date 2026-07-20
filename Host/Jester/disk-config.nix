{

  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                ];
              };
            };
            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "cryptroot";
                # disable settings.keyFile if you want to use interactive password entry
                passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  # keyFile = "/tmp/secret.key";
                };
                extraOpenArgs = [
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "nixos"
                    "-f"
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "subvol=root"
                        "compress=zstd:1"
                        "noatime"
                        "ssd"
                        "discard=async"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "subvol=home"
                        "compress=zstd:1"
                        "noatime"
                        "ssd"
                        "discard=async"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "subvol=nix"
                        "compress=zstd:1"
                        "noatime"
                        "ssd"
                        "discard=async"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      mountOptions = [
                        "subvol=swap"
                        "compress=zstd:1"
                        "compress=no"
                        "ssd"
                      ];
                      swap.swapfile.size = "34G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # fileSystems."/persist".neededForBoot = true;
  # fileSystems."/var/log".neededForBoot = true;
}
