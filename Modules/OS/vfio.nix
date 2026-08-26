{
  pkgs,
  config,
  lib,
  ...
}:
# File describes setup for VFIO in use on jester.
{
  # 1. Enable virtualization & Looking Glass client
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
          "/dev/hpet", "/dev/vfio/vfio", "/dev/kvmfr0",
          "/dev/input/mice", "/dev/input/event*"
        ]
      '';
    };
  };

  # Increased from 5s to 20s to prevent systemd from hard-killing (SIGKILL) 
  # the VM during slow hybrid Windows shutdowns, which breaks vendor-reset.
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
    "kvm.io_uring=1" # Required for modern Looking Glass/QEMU memory allocations
    "kvmfr.static_size_mb=64"
    "kvmfr"
  ];

  # 3. Allow qemu/kvm users to access the memory device
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="irrelevancy", GROUP="kvm", MODE="0660"
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
        PARENT_BRIDGE="0000:02:00.0" # Upstream PCI bridge causing the sysfs cache lock

        if [ "$GUEST_NAME" = "win11" ]; then
          # --- STARTUP HOOK ---
          if [ "$OPERATION" = "prepare" ] && [ "$SUB_OPER" = "begin" ]; then
            if [ -d "/sys/bus/pci/drivers/amdgpu/$VIRTGPU" ]; then
              echo "$VIRTGPU" > /sys/bus/pci/drivers/amdgpu/unbind 2>/dev/null || true
            fi
            # Trigger vendor-reset right before attaching to VFIO
            if [ -e "/sys/bus/pci/devices/$VIRTGPU/reset_method" ]; then
              echo "device_specific" > "/sys/bus/pci/devices/$VIRTGPU/reset_method" 2>/dev/null || true
            fi
            echo "$VIRTGPU" > /sys/bus/pci/drivers/vfio-pci/bind 2>/dev/null || true
          fi

          # --- TEARDOWN / STOP HOOK ---
          if [ "$OPERATION" = "stopped" ] && [ "$SUB_OPER" = "end" ]; then

            # Wait loop: Ensure QEMU has fully closed file handles to VFIO devices
            for i in {1..10}; do
              if ! fuser -s /dev/vfio/* 2>/dev/null; then
                break
              fi
              sleep 0.5
            done
            sleep 1

            # Disable runtime power management suspension during teardown to avoid dirty states
            if [ -e "/sys/bus/pci/devices/$VIRTGPU/power/control" ]; then
              echo "on" > "/sys/bus/pci/devices/$VIRTGPU/power/control" 2>/dev/null || true
            fi

            # 1. Unbind the GPU from VFIO
            if [ -d "/sys/bus/pci/drivers/vfio-pci/$VIRTGPU" ]; then
              echo "$VIRTGPU" > /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
            fi

            # 2. Force-remove BOTH the GPU and its upstream parent bridge interface
            # This completely drops the stale 'ip_discovery' and 'mem_info' sysfs nodes
            if [ -f "/sys/bus/pci/devices/$VIRTGPU/remove" ]; then
              echo 1 > "/sys/bus/pci/devices/$VIRTGPU/remove"
            fi
            if [ -f "/sys/bus/pci/devices/$PARENT_BRIDGE/remove" ]; then
              echo 1 > "/sys/bus/pci/devices/$PARENT_BRIDGE/remove"
            fi
            sleep 2

            # 3. Rescan the PCIe tree to re-initialize clean parent and child devices
            echo 1 > /sys/bus/pci/rescan
            sleep 2

            # 4. Bind the fresh, clean GPU instance back to amdgpu
            if [ -d "/sys/bus/pci/devices/$VIRTGPU" ]; then
              echo "$VIRTGPU" > /sys/bus/pci/drivers/amdgpu/bind 2>/dev/null || true
            fi
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
