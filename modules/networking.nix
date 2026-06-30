{ ... }:
{
  # Connectivity: how the machine is reachable and how it joins the tailnet.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--ssh" ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
