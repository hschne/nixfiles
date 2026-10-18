{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/syncthing.nix
    ../../modules/desktop.nix
    ../../modules/hyprland.nix
    ../../modules/theming.nix
    ../../modules/audio.nix
    ../../modules/apps.nix
    ../../modules/voxtype.nix
    ../../modules/bluetooth.nix
    ../../modules/docker.nix
    ../../modules/android.nix
    ../../modules/wifi.nix
  ];

  networking.hostName = "rocinante";

  services.fwupd.enable = true;

  # Keep the personal tailnet separate from the system's ZAR connection.
  systemd.services.tailscale-personal = {
    description = "Personal Tailscale connection";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscaled --tun=userspace-networking --statedir=/var/lib/tailscale-personal --socket=/run/tailscale-personal/tailscaled.sock --port=41642 --socks5-server=127.0.0.1:1081";
      StateDirectory = "tailscale-personal";
      StateDirectoryMode = "0700";
      RuntimeDirectory = "tailscale-personal";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Forward the Syncthing GUI through the personal tailnet on loopback only.
  systemd.services.anubis-syncthing-gui = {
    description = "Local access to anubis Syncthing GUI";
    wantedBy = [ "multi-user.target" ];
    requires = [ "tailscale-personal.service" ];
    after = [ "tailscale-personal.service" ];
    serviceConfig = {
      User = "hschne";
      ExecStart = ''${pkgs.socat}/bin/socat TCP4-LISTEN:18384,bind=127.0.0.1,reuseaddr,fork "EXEC:${pkgs.tailscale}/bin/tailscale --socket=/run/tailscale-personal/tailscaled.sock nc 100.68.130.10 8384"'';
      Restart = "on-failure";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };

  services.syncthing.settings.devices."Anubis" = {
    id = "XKCUYNX-5YNGOCQ-K3DVKK4-2F23UOW-E2MEM53-URT5FFE-PFBHGHF-LLSQQAI";
  };

  services.syncthing.settings.folders = {
    "Documents" = {
      id = "d6pbp-k3jur";
      path = "/home/hschne/Documents";
      devices = [
        "Diskstation"
        "Anubis"
      ];
      type = "sendreceive";
    };
    "Pictures" = {
      id = "7epys-jcu7w";
      path = "/home/hschne/Pictures";
      devices = [
        "Diskstation"
        "Anubis"
      ];
      type = "sendreceive";
    };
    "Videos" = {
      id = "dxnw7-fqqfc";
      path = "/home/hschne/Videos";
      devices = [
        "Diskstation"
        "Anubis"
      ];
      type = "sendreceive";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.plymouth.enable = true;
  boot.plymouth.theme = "bgrt";
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  # Compressed RAM swap so heavy dev workloads (Android emulator) stop paging out to nvme.
  zramSwap.enable = true;

  # Radeon/WiFi firmware + AMD microcode.
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  system.nixos.label = "NixOS";

  # Console login only; SSH stays key-only. Change with `passwd`.
  users.users.hschne.initialPassword = "nixos";

  system.stateVersion = "25.11";
}
