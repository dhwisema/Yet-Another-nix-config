{
  pkgs,
  config,
  lib,
  ...
}:
#file descirbes setup for vfio in use on jester.
{
  # 1. Enable virtualization & Looking Glass clientd
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      verbatimConfig = ''
        namespaces = []
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm", "/dev/rtc",
          "/dev/hpet", "/dev/vfio/vfio", "/dev/kvmfr0"
        ]
        virtiofsd = "${pkgs.virtiofsd}/bin/virtiofsd"
      '';
    };
  };
  systemd.services.libvirtd.serviceConfig.TimeoutStopSec = "5s";
  systemd.services.libvirt-guests.serviceConfig.TimeoutStopSec = "5s";
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  environment.systemPackages = with pkgs; [
    looking-glass-client
    virt-viewer
    qemu
    virtiofsd
  ];

  # 2. Add kvmfr module for Looking Glass memory sharing
  boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
  boot.kernelModules = [
    "kvmfr"
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
  ];
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "kvmfr.static_size_mb=64"
    "kvmfr"
  ];

  # 3. Allow qemu/kvm users to access the memory device
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr",OWNER="irrelevancy" GROUP="kvm", MODE="0660"
  '';

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 root kvm -"
  ];

  system.activationScripts.virtiofsd = ''
  mkdir -p /usr/libexec /usr/lib
  ln -sfn ${pkgs.virtiofsd}/bin/virtiofsd /usr/libexec/virtiofsd
  ln -sfn ${pkgs.virtiofsd}/bin/virtiofsd /usr/lib/virtiofsd
'';

  # 4. Add your user to necessary groups
  users.users.irrelevancy.extraGroups = [
    "kvm"
    "libvirtd"
  ];
}
