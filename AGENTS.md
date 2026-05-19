# nixfiles agent context

NixOS configuration for Hans's hosts, managed as a flake.

## Workflow — non-negotiable

- **Edit locally, push, then pull and rebuild on the remote host.**
- Never edit files directly on a remote host (no SSH + sed, no SSH + tee, nothing).
- The only commands that run over SSH are `git pull` and `sudo nixos-rebuild switch`.

## Repo layout

```
flake.nix               # Flake inputs (nixpkgs unstable, agenix)
modules/base.nix        # Shared packages and settings for all hosts
hosts/anubis/           # Host-specific config (imports base.nix + modules)
secrets/                # agenix-encrypted secrets
```

## Hosts

| Host   | Role                             | Access                   |
| ------ | -------------------------------- | ------------------------ |
| anubis | Headless NixOS devbox on Proxmox | `ssh anubis` (Tailscale) |

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
