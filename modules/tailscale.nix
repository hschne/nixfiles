{ ... }:
{
  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--ssh" ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
