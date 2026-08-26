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
          "/dev/null"
          "/dev/full"
          "/dev/zero"
          "/dev/random"
          "/dev/urandom"
          "/dev/ptmx"
          "/dev/kvm"
          "/dev/rtc"
          "/dev/hpet"
          "/dev/vfio/vfio"
          "/dev/kvmfr0"
          "/dev/input/mice"
          "/dev/input/event*"
        ]
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
    SUBSYSTEM=="kvmfr", \
      OWNER="irrelevancy", \
      GROUP="kvm", \
      MODE="0660"

    ACTION=="add", \
      SUBSYSTEM=="pci", \
      ATTR{vendor}=="0x1002", \
      ATTR{device}=="0x743f", \
      ATTR{power/control}="auto"
  '';

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 root kvm -"
  ];

  #
  # GPU passthrough hook
  #

  systemd.services.libvirtd.preStart =
    let

      qemuHook = pkgs.writeShellScript "qemu-hook" ''
        #!/bin/sh

        GUEST="$1"
        OPERATION="$2"
        SUB_OPERATION="$3"

        GPU="0000:03:00.0"

        if [ "$GUEST" != "win11" ]; then
          exit 0
        fi

        #
        # VM START
        #
        # amdgpu -> vfio-pci
        #

        if [ "$OPERATION" = "prepare" ] &&
           [ "$SUB_OPERATION" = "begin" ]; then

          echo "VFIO: preparing $GPU"

          #
          # Prevent runtime PM while switching drivers.
          #
          if [ -e "/sys/bus/pci/devices/$GPU/power/control" ]; then
            echo on > \
              "/sys/bus/pci/devices/$GPU/power/control" \
              2>/dev/null || true
          fi

          #
          # Unbind amdgpu.
          #
          if [ -L "/sys/bus/pci/drivers/amdgpu/$GPU" ]; then

            echo "$GPU" > \
              /sys/bus/pci/drivers/amdgpu/unbind \
              2>/dev/null || true

            sleep 1
          fi

          #
          # Bind VFIO.
          #
          if [ ! -L "/sys/bus/pci/drivers/vfio-pci/$GPU" ]; then

            echo "$GPU" > \
              /sys/bus/pci/drivers/vfio-pci/bind \
              2>/dev/null || true

          fi

          #
          # Wait for VFIO ownership.
          #
          for i in $(seq 1 20); do

            if [ -L "/sys/bus/pci/drivers/vfio-pci/$GPU" ]; then
              echo "VFIO: $GPU bound to vfio-pci"
              break
            fi

            sleep 0.25
          done

          exit 0
        fi

        #
        # VM STOP
        #
        # vfio-pci -> amdgpu
        #

        if [ "$OPERATION" = "stopped" ] &&
           [ "$SUB_OPERATION" = "end" ]; then

          echo "VFIO: restoring $GPU"

          #
          # Wait for QEMU to release VFIO.
          #
          for i in $(seq 1 40); do

            if ! fuser -s /dev/vfio/* 2>/dev/null; then
              break
            fi

            sleep 0.5
          done

          sleep 1

          #
          # Keep GPU powered during transition.
          #
          if [ -e "/sys/bus/pci/devices/$GPU/power/control" ]; then
            echo on > \
              "/sys/bus/pci/devices/$GPU/power/control" \
              2>/dev/null || true
          fi

          #
          # Unbind VFIO.
          #
          if [ -L "/sys/bus/pci/drivers/vfio-pci/$GPU" ]; then

            echo "$GPU" > \
              /sys/bus/pci/drivers/vfio-pci/unbind \
              2>/dev/null || true

            sleep 1
          fi

          #
          # IMPORTANT:
          #
          # Do NOT:
          #
          #   echo 1 > /sys/bus/pci/devices/.../remove
          #   echo 1 > /sys/bus/pci/devices/.../remove
          #   echo 1 > /sys/bus/pci/rescan
          #
          # We leave the PCI device and its parent bridge intact.
          #

          #
          # Rebind amdgpu.
          #
          if [ -e "/sys/bus/pci/devices/$GPU/driver" ]; then

            DRIVER="$(
              basename \
              "$(readlink "/sys/bus/pci/devices/$GPU/driver")"
            )"

            if [ "$DRIVER" != "amdgpu" ]; then

              echo "$GPU" > \
                /sys/bus/pci/drivers/amdgpu/bind \
                2>/dev/null || true

            fi

          else

            echo "$GPU" > \
              /sys/bus/pci/drivers/amdgpu/bind \
              2>/dev/null || true

          fi

          #
          # Wait for amdgpu.
          #
          for i in $(seq 1 40); do

            if [ -L "/sys/bus/pci/drivers/amdgpu/$GPU" ]; then
              echo "VFIO: $GPU restored to amdgpu"
              break
            fi

            sleep 0.25
          done

          #
          # Return runtime PM to normal.
          #
          if [ -e "/sys/bus/pci/devices/$GPU/power/control" ]; then
            echo auto > \
              "/sys/bus/pci/devices/$GPU/power/control" \
              2>/dev/null || true
          fi

          exit 0
        fi
      '';

    in
    ''
      mkdir -p /etc/libvirt/hooks
      ln -sf ${qemuHook} /etc/libvirt/hooks/qemu
    '';

  users.users.irrelevancy.extraGroups = [
    "kvm"
    "libvirtd"
  ];
}
