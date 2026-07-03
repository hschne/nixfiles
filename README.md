# nixfiles

NixOS host configuration for my machines.

## Building the installer ISO

The stock NixOS minimal ISO ships NetworkManager without a WiFi supplicant, so
WiFi shows up as unavailable. `hosts/installer` fixes that (NetworkManager +
iwd) and bundles a snapshot of this repo at `/etc/nixfiles`.

Build the ISO:

```bash
nix build .#installer-iso
ls result/iso/*.iso
```

Burn it to a USB stick (replace `/dev/sdX` with the target device — check with
`lsblk` first, this erases the stick):

```bash
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M conv=fsync status=progress
sync
```
