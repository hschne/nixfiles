# nixfiles

## Deployment

Edit repository source locally. Synchronize authorized changes to the target before rebuilding; use SSH for diagnostics, secret provisioning, and service operations.

Verify the requested service through the user's access path before declaring deployment complete; server-local health checks are insufficient.

## Rocinante networking

Work and personal Tailscale run simultaneously. For personal-network access, inspect the personal service in `hosts/rocinante/default.nix` before recommending account switching: the default CLI reports the work instance, and the userspace personal instance does not provide ordinary network routing.

## Comments

Keep comments to one line explaining intent.
