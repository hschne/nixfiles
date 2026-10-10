{ pkgs, ... }:
{
  # Let ordinary browsers reach Photos without changing the work tailnet.
  networking.extraHosts = ''
    127.0.0.1 photos.schnedlitz.family
  '';

  systemd.services.personal-photos = {
    description = "Local HTTPS access to Photos through personal Tailscale";
    wantedBy = [ "multi-user.target" ];
    requires = [ "tailscale-personal.service" ];
    after = [ "tailscale-personal.service" ];
    serviceConfig = {
      User = "hschne";
      ExecStart = ''${pkgs.socat}/bin/socat TCP4-LISTEN:443,bind=127.0.0.1,reuseaddr,fork "EXEC:${pkgs.tailscale}/bin/tailscale --socket=/run/tailscale-personal/tailscaled.sock nc 100.68.130.10 443"'';
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      Restart = "on-failure";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };
}
