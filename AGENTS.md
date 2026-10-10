# nixfiles

NixOS host configurations, managed as a flake. Inspect `flake.nix` and `hosts/<name>/default.nix` for host imports and outputs.

## Deployment

Edit repository files locally, commit/push when authorized, then pull and rebuild on the target. SSH is also available for secrets, diagnostics, and service operations.

```bash
ssh anubis 'cd ~/Source/nixfiles && git pull --ff-only && sudo nixos-rebuild switch --flake .#anubis'
```

Verify the requested service from the user's access path before declaring deployment complete; server-local health checks alone are insufficient.

## Personal Tailscale on Rocinante

Work and personal Tailscale run simultaneously. Inspect the personal service in `hosts/rocinante/default.nix` before recommending account switching; the default CLI only reports the work instance.

`modules/personal-photos.nix` provides ordinary browser access to Photos through a loopback bridge into personal Tailscale. The userspace personal instance does not otherwise provide normal network routing.

## Conventions

- Keep comments to one line explaining intent.
- Keep fzf shell integration in user dotfiles, not global NixOS settings.
- Install mise-managed tools per user with `mise install`.
