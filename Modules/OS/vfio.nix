{
  pkgs,
  config,
  lib,
  ...
}:
  let
  gpuPassthroughHook = pkgs.writeShellScript "gpu-passthrough-hook" ''
    #!${pkgs.bash}/bin/bash

    set -euo pipefail

    VM="$1"
    OP="$2"

    GPU="0000:03:00.0"
    PARENT="0000:02:00.0"

    GPU_PATH="/sys/bus/pci/devices/$GPU"
    VFIO_PATH="/sys/bus/pci/drivers/vfio-pci"
    AMDGPU_PATH="/sys/bus/pci/drivers/amdgpu"

    log() {
      echo "[gpu-passthrough] $*"
      ${pkgs.systemd}/bin/logger -t gpu-passthrough -- "$*"
    }

    wait_for_unbind() {
      local timeout=50

      while [ "$timeout" -gt 0 ]; do
        if [ ! -L "$GPU_PATH/driver" ]; then
          return 0
        fi

        sleep 0.1
        timeout=$((timeout - 1))
      done

      log "ERROR: GPU did not unbind"
      return 1
    }

    wait_for_bind() {
      local expected="$1"
      local timeout=50

      while [ "$timeout" -gt 0 ]; do
        if [ -L "$GPU_PATH/driver" ]; then
          if [ "$(basename "$(readlink "$GPU_PATH/driver")")" = "$expected" ]; then
            return 0
          fi
        fi

        sleep 0.1
        timeout=$((timeout - 1))
      done

      log "ERROR: GPU did not bind to $expected"
      return 1
    }

    bind_vfio() {
      log "Preparing $GPU for VFIO"

      # If amdgpu currently owns the GPU, release it.
      if [ -L "$GPU_PATH/driver" ]; then
        DRIVER="$(basename "$(readlink "$GPU_PATH/driver")")"

        if [ "$DRIVER" = "amdgpu" ]; then
          log "Unbinding $GPU from amdgpu"
          echo "$GPU" > "$AMDGPU_PATH/unbind"
          wait_for_unbind
        elif [ "$DRIVER" != "vfio-pci" ]; then
          log "ERROR: GPU is bound to unexpected driver: $DRIVER"
          return 1
        fi
      fi

      # Make sure vfio-pci is available.
      ${pkgs.kmod}/bin/modprobe vfio-pci

      # Explicitly bind the device to vfio-pci.
      if [ ! -L "$GPU_PATH/driver" ]; then
        log "Binding $GPU to vfio-pci"
        echo "$GPU" > "$VFIO_PATH/bind"
      fi

      wait_for_bind vfio-pci

      log "$GPU is now bound to vfio-pci"
    }

    bind_amdgpu() {
      log "Returning $GPU to amdgpu"

      # Remove it from vfio-pci if necessary.
      if [ -L "$GPU_PATH/driver" ]; then
        DRIVER="$(basename "$(readlink "$GPU_PATH/driver")")"

        if [ "$DRIVER" = "vfio-pci" ]; then
          log "Unbinding $GPU from vfio-pci"
          echo "$GPU" > "$VFIO_PATH/unbind"
          wait_for_unbind
        elif [ "$DRIVER" != "amdgpu" ]; then
          log "ERROR: GPU is bound to unexpected driver: $DRIVER"
          return 1
        else
          log "$GPU is already bound to amdgpu"
          return 0
        fi
      fi

      # Rescan PCI so the device is visible to the driver again.
      log "Rescanning PCI bus"
      echo 1 > /sys/bus/pci/rescan

      # Explicitly bind to amdgpu.
      if [ ! -L "$GPU_PATH/driver" ]; then
        log "Binding $GPU to amdgpu"
        echo "$GPU" > "$AMDGPU_PATH/bind"
      fi

      wait_for_bind amdgpu

      log "$GPU is now bound to amdgpu"
    }

    case "$VM:$OP" in
      win11:prepare|win11:release)
        # These are the libvirt qemu.d lifecycle events we care about.
        ;;

      *)
        exit 0
        ;;
    esac

    case "$OP" in
      prepare)
        bind_vfio
        ;;

      release)
        bind_amdgpu
        ;;
    esac
  '';

in


{
  virtualisation.libvirtd = {
    enable = true;
    hooks.qemu = {gpu-passthrough = gpuPassthroughHook;};
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
