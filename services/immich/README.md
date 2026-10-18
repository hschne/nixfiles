# Immich on Anubis

Public URL: https://photos.schnedlitz.family (Immich authentication required).

## Configuration

- `docker-compose.yaml`: pinned Immich v3.3.3 server and CPU machine-learning images, its release's PostgreSQL/Valkey images, and Traefik. No Docker socket mount.
- `immich.json`: machine learning enabled with explicit v3.3.3 default models and thresholds for facial recognition, smart search, duplicate detection, and OCR; storage templates enabled, originals organized by year/month/original filename.
- `traefik.toml` and `routes.toml`: HTTPS and Cloudflare DNS challenge.
- `../../modules/immich.nix`: Docker, directory permissions, Compose lifecycle, LAN HTTPS access, and IPv4-only Cloudflare dynamic DNS. Existing SSH and Tailscale access is unchanged.

Immich config-file mode disables system-settings edits in the UI, including settings omitted from the file. Accounts, libraries, and albums remain editable. Edit `immich.json` and rebuild for system-setting changes.

## Storage

| Content                                                                         | Host path                      |
| ------------------------------------------------------------------------------- | ------------------------------ |
| Managed originals after storage-template processing                             | `/home/hschne/Pictures/Photos` |
| Upload staging, previews, thumbnails, converted videos, avatars, database dumps | `/var/lib/immich/data`         |
| Machine-learning model cache                                                    | `/var/lib/immich/model-cache`  |
| PostgreSQL                                                                      | `/var/lib/immich/postgres`     |
| Certificate keys                                                                | `/var/lib/immich/traefik`      |

`Pictures/Photos` is mounted over `/data/library`; it is already covered by the Pictures Syncthing folder. It contains per-user directories, then the storage-template paths. New uploads remain outside Syncthing until Immich moves them from staging into the managed library. Do not modify managed files through Syncthing peers or a file manager; Immich's database tracks them. Existing Pictures/Camera and other folders are unchanged.

The automatic database dumps remain enabled under `/var/lib/immich/data/backups`. They are not an off-host backup. Backups and bulk migration are deferred; retain old originals.

## First deployment

1. Provision `/var/lib/immich/cloudflare-token` over SSH, owned by root with mode 0600. Use a Cloudflare API token scoped to `schnedlitz.family`, with Zone DNS Edit and Zone Read permissions. Do not use the workstation's `cf` OAuth credentials. The service fails clearly if this token is absent.
2. Commit/push the local changes when authorized, then pull and rebuild on Anubis. Never edit repository files remotely.
3. The service generates `/var/lib/immich/database.env` once, with a random database password and mode 0600. Do not delete or replace it after database initialization.
4. Create the admin account yourself before enabling router forwarding. There is no provisioning/bootstrap script or external library.
5. Upload a few test photos and verify they appear under `Pictures/Photos`, then on Diskstation/Rocinante via Syncthing. Check that previews, avatars, and dumps stay outside Pictures.
6. Configure the Immich phone app to use the public URL and selected phone albums. Keep the old camera sync until upload behavior is verified.

## Public access

- ASUS RT-AX58U reserves `192.168.50.53` for Anubis's Ethernet MAC `C0:25:A5:AE:4D:A2`; existing reservations are preserved.
- The router forwards TCP 443 only to `192.168.50.53:443`; no port 80 or 2283 forwarding, no DMZ, and WAN router administration remains disabled. UPnP is unchanged.
- Traefik publishes only `192.168.50.53:443` and `100.68.130.10:443`; the app, database, cache, and ML service have no published ports.
- Cloudflare holds a DNS-only A record for `photos.schnedlitz.family`; no AAAA record is configured. Photo traffic does not traverse Cloudflare's proxy.
- NixOS's `cloudflare-dyndns` service checks the public IPv4 address every five minutes using the existing zone-scoped token via systemd credentials.
- Certificates still use DNS challenges, so inbound port 80 is unnecessary. Traefik's 30-minute timeouts support large video uploads.
- Router settings are applied through its admin UI, not managed by NixOS; the reservation and forwarding rule above must be restored if the router is reset.

For verification, use mobile data with Wi-Fi and Tailscale off: log in, upload a video larger than 100 MB, and check playback. A LAN test against the public address checks hairpin NAT but is not an external reachability test.

## Machine learning

The CPU-only ML service is reachable only inside the Compose network. It downloads models on first use into `/var/lib/immich/model-cache`, outside Syncthing. The image version matches the server; update both together.

ML settings are managed in `immich.json`, not the admin UI. New uploads use the enabled features automatically. To process existing assets after enabling ML, run the missing Smart Search, Face Detection, Facial Recognition, and OCR jobs from Administration → Job Queues. Face detection must finish before facial recognition can group faces. Verify a small batch in the People view before starting a bulk import.

Face names and groupings live in PostgreSQL, not in the synced originals; the model cache is not a backup of that metadata.

## Operations

NixOS runs Compose against the immutable configuration directory in the Nix store. For direct operations using this checkout:

```bash
sudo docker compose --project-name immich \
  --env-file /var/lib/immich/database.env \
  -f services/immich/docker-compose.yaml ps
```

Change pinned image versions and configuration locally, then push/pull/rebuild. For Immich upgrades, use the database/cache images from the matching upstream release Compose file.

After deployment, keep an existing SSH session open while testing a fresh `ssh anubis` connection. Verify the proxy only publishes `192.168.50.53:443` and `100.68.130.10:443`, the app/database/cache/ML service have no host ports, and the stack starts after a reboot. Reboot testing should be scheduled separately from the initial deployment.
