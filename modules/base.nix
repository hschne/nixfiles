{ pkgs, ... }:
{
  # Bare necessities to bring a host up and operate it. Anything interactive
  # or workflow-specific belongs in cli.nix / dev.nix / feature modules.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Europe/Vienna";

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  users.users.hschne = {
    isNormalUser = true;
    description = "Hans Schnedlitz";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT22cRCeqhk1u60725JZGb16dHpxrK5PeskeprGEcoA hschne@anubis"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Allow prebuilt binaries (e.g. mise-managed runtimes) to run on NixOS.
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    neovim
    nixfmt
    htop
    rsync
    unzip
    zip
    gzip
    tree
    less
    file
  ];
}
