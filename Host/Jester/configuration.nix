{
  pkgs,
  config,
  lib,
  ...
}:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  services.tlp.enable = pkgs.lib.mkForce false;

  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
    "amd_iommu=on"
    "iommu=pt"
  ]; # disable psr-su
  boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
  boot.kernelModules = [
    "vfio"
    "vfio_iommu_type1"
    "vfio_pci"
    "kvmfr"
  ];
  boot.extraModprobeConfig = ''
    options kvmfr static_size_mb=64
  '';

services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", OWNER="irrelevancy", GROUP="kvm", MODE="0660"
  '';
systemd.tmpfiles.rules = [
  "f /dev/shm/looking-glass 0660 root kvm -"
];
  environment.systemPackages = [
    pkgs.qemu
    pkgs.looking-glass-client
  ];
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
  systemd.services.wifi-fix = {
    enable = true;
    after = [
      "suspend.target"
      "hibernate.target"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
    ];
    description = "fix qcnfa wifi";
    script = ''
      ${pkgs.kmod}/bin/rmmod ath11k_pci ath11k && ${pkgs.kmod}/bin/modprobe ath11k_pci ath11k
    '';
    serviceConfig = {
      Type = "oneshot";

    };
  };

  #iso use only networking.networkmanager.enable = lib.mkForce false;

  #boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

}
