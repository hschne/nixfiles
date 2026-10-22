# nixfiles

NixOS configurations for Anubis and Rocinante. Host-specific configuration lives in `hosts/`; shared configuration lives in `modules/`.

## Usage

```bash
sudo nixos-rebuild switch --flake .#<host>
nix build .#installer-iso
```

## Operations

- Immich: https://photos.schnedlitz.family. Manage originals through Immich, not through Syncthing or a file manager; its database tracks those files.
- The daily personal backup job first pauses Immich for a consistent media/SQL backup; weekly jobs copy the latest recovery point for each dataset offsite and maintain the NAS repository. Schedules and retention live in `hosts/anubis/backups/default.nix`. Do not run imports or rebuild/restart Immich during its backup. Syncthing is not a backup.
- Retention counts are not storage quotas. Budget for unique data growth, retained deleted/changed files, and pruning workspace. Hetzner's separate Storage Box snapshot plan also consumes its quota; keep it small rather than duplicating Restic's full history.
- Anubis's interface and addresses are defined in `hosts/anubis/network.nix`. Its router DHCP reservation and TCP 443 forwarding are outside Nix; preserve them when replacing or resetting the router.
- Diskstation runs DSM, outside the flake. Its recorded `syncthing.service` is installed manually as `/etc/systemd/system/anubis-syncthing.service`.

## Anubis agent access

Paseo is managed by `paseo.service`, runs as `hschne`, and listens only on Anubis's personal Tailscale address on port 6767. The hosted relay is disabled. Connect Razorback through Paseo's **Add host → Direct connection**, with SSL off; Tailscale encrypts the connection. Rocinante's personal tailnet uses userspace networking, so use its SOCKS proxy or a local forward rather than an ordinary TCP connection.

Bootstrap the user environment with `YADM_BOOTSTRAP_PROFILE=server yadm bootstrap` after cloning dotfiles. Provider logins, Paseo's password hash, and session history are runtime state, not Nix or dotfiles inputs. Paseo remains stopped until `~/.paseo/config.json` exists and contains a bcrypt password hash. As `hschne`, run `paseo daemon set-password`, then `sudo systemctl start paseo`. Restart through systemd, not `paseo daemon start` or `paseo daemon restart`.

Nix owns the listener, disabled relay and service environment. Keep mutable settings in `~/.paseo/config.json`; setting `services.paseo.settings` would replace that file on every service start. Access to Paseo grants control over agents running with `hschne`'s filesystem access and sudo rights; use a unique password and restrict tailnet grants accordingly.

## Secret recovery

Encrypted files and recipient rules live in `hosts/anubis/secrets/`. Anubis decrypts them with its SSH host key. The independent recovery identity is in Proton Pass → Personal → **Agenix Key**; individual backup credentials are under **Anubis Backup**.

For a replacement host key, update its public recipient in `secrets.nix`, then rekey using a protected temporary copy of the recovery identity:

```bash
cd hosts/anubis/secrets
nix run ../../..#agenix -- -i /path/to/recovery-identity -r
```

Remove the exported identity after use. Keep its recovery copy independent of Anubis.

Before first activation on a replacement machine, provision its SSH host identity or generate a new one and rekey. Restore Tailscale state or authenticate the replacement node; restore Syncthing's identity before starting synchronization, or explicitly reauthorize the new device.

Immich's existing database credential and the Cloudflare DNS token are also managed by agenix. The token serves Traefik's DNS challenge and dynamic DNS, not Immich itself. Preserve the matching database credential when reusing a physical PostgreSQL data directory.

NAS accounts, authorized keys, and repository directories are external provisioning prerequisites. When changing a backup endpoint, verify its SSH identity and update `known_hosts` too.
