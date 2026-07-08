# nixfiles agent context

NixOS configuration for Hans's hosts, managed as a flake.

## Workflow — non-negotiable

- **Edit locally, push, then pull and rebuild on the remote host.**
- Never edit files directly on a remote host (no SSH + sed, no SSH + tee, nothing).
- The only commands that run over SSH are `git pull` and `sudo nixos-rebuild switch`.

## Repo layout

```
flake.nix               # Inputs (nixpkgs unstable) and host outputs
modules/common.nix      # Baseline every host imports (user, SSH, CLI, toolchain)
modules/*.nix           # Feature modules (desktop, audio, apps, docker, ...)
hosts/<name>/           # Host config (imports common.nix + feature modules)
packages/               # Custom package derivations
```

## Hosts

| Host      | Role                             | Access                      |
| --------- | -------------------------------- | --------------------------- |
| anubis    | Headless NixOS devbox on Proxmox | `ssh anubis` (Tailscale)    |
| rocinante | AMD laptop (Hyprland desktop)    | local                       |
| installer | Bootable ISO for metal installs  | `nix build .#installer-iso` |

## Applying changes to anubis

```bash
# 1. Edit locally
# 2. Commit and push
cd ~/Source/nixfiles && git add -A && git commit -m "..." && git push

# 3. Pull and rebuild on anubis
ssh anubis "cd ~/Source/nixfiles && git pull && sudo nixos-rebuild switch --flake ~/Source/nixfiles#anubis"
```

## Notes

- `nixpkgs` tracks `nixos-unstable`.
- `ZI_BIN_DIR` is set via `environment.sessionVariables` to the Nix-provided zinit path.
- `programs.fzf.keybindings` and `programs.fzf.fuzzyCompletion` are enabled — do not add fzf key-binding setup to dotfiles.
- mise is installed as a system package; tools are installed per-user via `mise install`.
