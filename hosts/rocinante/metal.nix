# Real-hardware knobs for rocinante (the VirtualBox equivalents lived in the
# now-removed vm.nix). Imported by default.nix instead of vm.nix.
{ ... }:
{
  # Keep the 2 GB ESP from filling up with old generations.
  boot.loader.systemd-boot.configurationLimit = 10;

  # GPU/WiFi firmware + AMD microcode for the Ryzen/Radeon 760M laptop.
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
}
