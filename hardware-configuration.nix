# Hand-written hardware defaults for a modern Intel + NVIDIA laptop.
#
# Filesystems are intentionally NOT declared here — disko.nix owns them.
#
# These initrd modules cover the common laptop boot path (NVMe, USB boot,
# SD reader, Thunderbolt). If the machine fails to boot or you want exact
# values, regenerate on-device with:
#   nixos-generate-config --no-filesystems --root /mnt
# and replace the lists below with the generated `hardware-configuration.nix`.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # LUKS root must be unlocked in initrd. disko emits the crypttab/luks
  # entries; this just ensures the systemd-stage-1 initrd is used so the
  # passphrase prompt works cleanly.
  boot.initrd.systemd.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = true;
}
