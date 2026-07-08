# nixfiles

My NixOS host configuration.

## Hosts

- **anubis** — headless devbox on Proxmox
- **rocinante** — AMD laptop with Hyprland

## Rebuild

```bash
sudo nixos-rebuild switch --flake .#<host>
```

## Installer ISO

```bash
nix build .#installer-iso
```

Burn it to a USB stick:

```bash
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M conv=fsync status=progress
sync
```
