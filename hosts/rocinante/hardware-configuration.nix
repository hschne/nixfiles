# METAL TEMPLATE - regenerate on the target machine.
#
# During install the runbook runs `nixos-generate-config --root /mnt`, which
# writes the real device UUIDs (LUKS container, root, ESP, swap) and detected
# kernel modules. Copy that generated file over this one before nixos-install,
# or replace the REPLACE-* UUIDs below with the values from `blkid`.
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # LUKS container on the freed Windows space.
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/REPLACE-LUKS-UUID";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-ROOT-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-ESP-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Reused existing 8 GB swap partition (nvme0n1p5).
  swapDevices = [
    { device = "/dev/disk/by-uuid/REPLACE-SWAP-UUID"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
