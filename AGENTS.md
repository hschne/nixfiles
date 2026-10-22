# nixfiles

## Deployment

Follow the nixfiles skill's build-and-deploy procedure: build locally and deploy the closure over SSH by default, without synchronizing or pulling the repository on the target. The skill owns activation sequencing, recovery precautions, and user-path verification.

## Rocinante networking

Work and personal Tailscale run simultaneously. For personal-network access, inspect the personal service in `hosts/rocinante/default.nix` before recommending account switching: the default CLI reports the work instance, and the userspace personal instance does not provide ordinary network routing.

## Comments

Keep comments to one line explaining intent.
