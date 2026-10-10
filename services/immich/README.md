# Immich on Anubis

Private URL: https://photos.schnedlitz.family (Tailscale required).

## Configuration

- `docker-compose.yaml`: pinned Immich v3.3.1, its release's PostgreSQL/Valkey images, and Traefik. No machine-learning container or Docker socket mount.
- `immich.json`: machine learning disabled, storage templates enabled, originals organized by year/month/original filename.
- `traefik.toml` and `routes.toml`: private HTTPS and Cloudflare DNS challenge.
- `../../modules/immich.nix`: Docker, directory permissions, and Compose startup/shutdown. Existing SSH, firewall, and Tailscale settings are unchanged.

Immich config-file mode disables system-settings edits in the UI, including settings omitted from the file. Accounts, libraries, and albums remain editable. Edit `immich.json` and rebuild for system-setting changes.

## Storage

| Content                                                                         | Host path                      |
| ------------------------------------------------------------------------------- | ------------------------------ |
| Managed originals after storage-template processing                             | `/home/hschne/Pictures/Photos` |
| Upload staging, previews, thumbnails, converted videos, avatars, database dumps | `/var/lib/immich/data`         |
| PostgreSQL                                                                      | `/var/lib/immich/postgres`     |
| Certificate keys                                                                | `/var/lib/immich/traefik`      |

`Pictures/Photos` is mounted over `/data/library`; it is already covered by the Pictures Syncthing folder. It contains per-user directories, then the storage-template paths. New uploads remain outside Syncthing until Immich moves them from staging into the managed library. Do not modify managed files through Syncthing peers or a file manager; Immich's database tracks them. Existing Pictures/Camera and other folders are unchanged.

The automatic database dumps remain enabled under `/var/lib/immich/data/backups`. They are not an off-host backup. Backups and bulk migration are deferred; retain old originals.

## First deployment

1. Provision `/var/lib/immich/cloudflare-token` over SSH, owned by root with mode 0600. Use a Cloudflare API token scoped to `schnedlitz.family`, with Zone DNS Edit and Zone Read permissions. Do not use the workstation's `cf` OAuth credentials. The service fails clearly if this token is absent.
2. Commit/push the local changes when authorized, then pull and rebuild on Anubis. Never edit repository files remotely.
3. The service generates `/var/lib/immich/database.env` once, with a random database password and mode 0600. Do not delete or replace it after database initialization.
4. Open the private URL and create the admin account yourself. There is no provisioning/bootstrap script or external library.
5. Upload a few test photos and verify they appear under `Pictures/Photos`, then on Diskstation/Rocinante via Syncthing. Check that previews, avatars, and dumps stay outside Pictures.
6. Configure the Immich phone app to use the private URL and selected phone albums. Keep the old camera sync until upload behavior is verified.

## Operations

NixOS runs Compose against the immutable configuration directory in the Nix store. For direct operations using this checkout:

```bash
sudo docker compose --project-name immich \
  --env-file /var/lib/immich/database.env \
  -f services/immich/docker-compose.yaml ps
```

Change pinned image versions and configuration locally, then push/pull/rebuild. For Immich upgrades, use the database/cache images from the matching upstream release Compose file.

After deployment, keep an existing SSH session open while testing a fresh `ssh anubis` connection. Verify the proxy only publishes `100.68.130.10:443`, the app/database/cache have no host ports, and the stack starts after a reboot. Reboot testing should be scheduled separately from the initial deployment.
