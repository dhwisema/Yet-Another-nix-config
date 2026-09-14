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
    hooks.qemu = pkgs.writeShellScript "rx6500m-passthrough" ''
      GUEST_NAME="$1"
              ACTION="$2"
              STATE="$3"

              VIRSH_GPU_VIDEO="0000:03:00.0"
              VIRSH_GPU_AUDIO="0000:03:00.1"

              if [ "$GUEST_NAME" = "win11" ]; then
                if [ "$ACTION" = "prepare" ] && [ "$STATE" = "begin" ]; then
                  # Force GPU awake (disable d3cold)
                  echo "on" > "/sys/bus/pci/devices/$VIRSH_GPU_VIDEO/power/control"

                  # Unbind dGPU from host drivers
                  echo "$VIRSH_GPU_VIDEO" > "/sys/bus/pci/drivers/amdgpu/unbind" 2>/dev/null || true
                  echo "$VIRSH_GPU_AUDIO" > "/sys/bus/pci/drivers/snd_hda_intel/unbind" 2>/dev/null || true

                  # Load VFIO modules using Nix store kmod
                  ${pkgs.kmod}/bin/modprobe vfio
                  ${pkgs.kmod}/bin/modprobe vfio_pci
                  ${pkgs.kmod}/bin/modprobe vfio_iommu_type1

                  # Bind dGPU to vfio-pci
                  echo "vfio-pci" > "/sys/bus/pci/devices/$VIRSH_GPU_VIDEO/driver_override"
                  echo "$VIRSH_GPU_VIDEO" > "/sys/bus/pci/drivers/vfio-pci/bind"
                  echo "" > "/sys/bus/pci/devices/$VIRSH_GPU_VIDEO/driver_override"

                  echo "vfio-pci" > "/sys/bus/pci/devices/$VIRSH_GPU_AUDIO/driver_override"
                  echo "$VIRSH_GPU_AUDIO" > "/sys/bus/pci/drivers/vfio-pci/bind"
                  echo "" > "/sys/bus/pci/devices/$VIRSH_GPU_AUDIO/driver_override"

                elif [ "$ACTION" = "release" ] && [ "$STATE" = "end" ]; then
                  # Unbind from vfio-pci
                  echo "$VIRSH_GPU_VIDEO" > "/sys/bus/pci/drivers/vfio-pci/unbind" 2>/dev/null || true
                  echo "$VIRSH_GPU_AUDIO" > "/sys/bus/pci/drivers/vfio-pci/unbind" 2>/dev/null || true

                  # Re-bind to host drivers
                  echo "$VIRSH_GPU_VIDEO" > "/sys/bus/pci/drivers/amdgpu/bind" 2>/dev/null || true
                  echo "$VIRSH_GPU_AUDIO" > "/sys/bus/pci/drivers/snd_hda_intel/bind" 2>/dev/null || true

                  # Restore runtime power management
                  echo "auto" > "/sys/bus/pci/devices/$VIRSH_GPU_VIDEO/power/control"
                fi
              fi
    '';
  };
  boot.extraModulePackages = [
    config.boot.kernelPackages.kvmfr
  ];

  #  systemd.services.libvirtd.serviceconfig.timeoutstopsec = "20s";
  #  systemd.services.libvirt-guests.serviceconfig.timeoutstopsec = "20s";

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

  users.users.irrelevancy.extraGroups = [
    "kvm"
    "libvirtd"
  ];
}
