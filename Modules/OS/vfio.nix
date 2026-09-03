{
  pkgs,
  config,
  lib,
  ...
}:

{
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      vhostUserPackages = [
        pkgs.virtiofsd
      ];

      swtpm.enable = true;

      verbatimConfig = ''
        namespaces = []
        cgroup_device_acl = [
          "/dev/null",
          "/dev/full",
          "/dev/zero",
          "/dev/random",
          "/dev/urandom",
          "/dev/ptmx",
          "/dev/kvm",
          "/dev/rtc",
          "/dev/hpet",
          "/dev/vfio/vfio",
          "/dev/kvmfr0"        ]
      '';
    };
  };
  boot.extraModulePackages = [
    config.boot.kernelPackages.kvmfr
  ];

  systemd.services.libvirtd.serviceConfig.TimeoutStopSec = "20s";
  systemd.services.libvirt-guests.serviceConfig.TimeoutStopSec = "20s";

  programs.virt-manager.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    looking-glass-client
    virt-viewer
    qemu
    virtiofsd
  ];

  #
  # VFIO
  #

  boot.kernelModules = [
    "kvm"
    "kvm_amd"
    "kvmfr"
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"

    "kvmfr"
  ];

  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "kvm.io_uring=1"
    "kvmfr.static_size_mb=64"
  ];

  #
  # Looking Glass
  #

  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="irrelevancy", GROUP="kvm", MODE="0660"
    # Enable runtime PM for AMD dGPU when bound to amdgpu driver
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x743f", ATTR{power/control}="auto"  '';

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 root kvm -"
  ];

  #
  # GPU passthrough hook
  #

  users.users.irrelevancy.extraGroups = [
    "kvm"
    "libvirtd"
  ];
}
