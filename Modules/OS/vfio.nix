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
      vhostUserPackages = with pkgs; [ virtiofsd ];
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
  boot.extraModprobeConfig = ''
    softdep vfio-pci pre: vendor-reset
  '';

  # 2. Add kvmfr module for Looking Glass memory sharing
  boot.extraModulePackages = [
    config.boot.kernelPackages.kvmfr
    config.boot.kernelPackages.vendor-reset
  ];
  boot.kernelModules = [
    "kvm"
    "kvm_amd"
    "kvmfr"
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
    "vendor-reset"
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
    # Enable runtime PM for AMD dGPU when bound to amdgpu driver
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x743f", ATTR{power/control}="auto"
  '';
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 root kvm -"
  ];
systemd.services.libvirtd.preStart =
    let
      qemuHook = pkgs.writeShellScript "qemu-hook" ''
        GUEST_NAME="$1"
        OPERATION="$2"
        SUB_OPER="$3"

        VIRTGPU="0000:03:00.0"

        if [ "$GUEST_NAME" = "win11" ]; then
          # --- STARTUP HOOK ---
          if [ "$OPERATION" = "prepare" ] && [ "$SUB_OPER" = "begin" ]; then
            if [ -d "/sys/bus/pci/drivers/amdgpu/$VIRTGPU" ]; then
              echo "$VIRTGPU" > /sys/bus/pci/drivers/amdgpu/unbind 2>/dev/null || true
            fi
            echo "$VIRTGPU" > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
          fi

          # --- TEARDOWN / STOP HOOK ---
          if [ "$OPERATION" = "release" ] && [ "$SUB_OPER" = "end" ]; then
            if [ -d "/sys/bus/pci/drivers/vfio-pci/$VIRTGPU" ]; then
              echo "$VIRTGPU" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
            fi
            echo "$VIRTGPU" > /sys/bus/pci/drivers/amdgpu/bind 2>/dev/null || true
          fi
        fi
      '';
    in
    ''
      mkdir -p /etc/libvirt/hooks
      ln -sf ${qemuHook} /etc/libvirt/hooks/qemu
    '';
  # 4. Add your user to necessary groups
  users.users.irrelevancy.extraGroups = [
    "kvm"
    "libvirtd"
  ];
}
