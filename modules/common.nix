{ pkgs, ... }:
{
  imports = [ ./maintenance.nix ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

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

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale = {
    enable = true;
    # accept subnet routes and DNS from the tailnet
    useRoutingFeatures = "client";
    # operator lets hschne run tailscale commands without sudo
    extraSetFlags = [
      "--ssh"
      "--operator=hschne"
      "--accept-routes"
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Run prebuilt binaries (e.g. mise-managed runtimes) on NixOS.
  # libraries exposes shared libs these binaries dlopen (e.g. ruby-vips -> libvips).
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      vips
    ];
  };

  # FHS shebangs like /bin/bash in user scripts.
  services.envfs.enable = true;

  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;
  users.defaultUserShell = pkgs.zsh;

  environment.sessionVariables = {
    ZI_BIN_DIR = "${pkgs.zinit}";

    # Use the Secret Service keyring backend; the kernel keyring is session-bound.
    PROTON_PASS_LINUX_KEYRING = "dbus";
  };

  environment.systemPackages = with pkgs; [
    # Core
    coreutils
    git
    curl
    wget
    neovim
    marksman
    nixfmt
    htop
    rsync
    unzip
    zip
    gzip
    tree
    less
    file
    parted

    # Shell environment
    postgresql
    sqlite
    starship
    tmux
    util-linux
    yadm
    zinit

    # CLI tooling
    age
    awscli2
    bat
    btop
    bubblewrap
    ctags
    delta
    dust
    entr
    eza
    fastfetch
    fd
    fzf
    gh
    gnupg
    hcloud
    httpie
    jq
    lazygit
    mise
    p7zip
    proton-pass-cli
    ripgrep
    silicon
    ssm-session-manager-plugin
    yazi
    yq
    zoxide

    # Build toolchain; openssl for mise-compiled runtimes
    gcc
    gnumake
    openssl
    pkg-config
    postgresql.pg_config
    vips
  ];
}
