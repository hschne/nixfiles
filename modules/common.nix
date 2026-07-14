{ pkgs, ... }:
{
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
    extraSetFlags = [ "--ssh" ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Run prebuilt binaries (e.g. mise-managed runtimes) on NixOS.
  programs.nix-ld.enable = true;

  # FHS shebangs like /bin/bash in user scripts.
  services.envfs.enable = true;

  programs.zsh.enable = true;
  programs.fzf.keybindings = true;
  programs.fzf.fuzzyCompletion = true;
  users.defaultUserShell = pkgs.zsh;

  environment.sessionVariables = {
    ZI_BIN_DIR = "${pkgs.zinit}";

    # Use the Secret Service keyring backend; the kernel keyring is session-bound.
    PROTON_PASS_LINUX_KEYRING = "dbus";

    # Add systemPackages to the default linker path.
    LD_LIBRARY_PATH = "${pkgs.vips}/lib";
  };

  environment.systemPackages = with pkgs; [
    # Core
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

    # Shell environment
    tmux
    starship
    yadm
    zinit

    # CLI tooling
    eza
    bat
    fd
    ripgrep
    zoxide
    jq
    yq
    dust
    delta
    gh
    lazygit
    httpie
    ctags
    entr
    mise
    yazi
    silicon
    p7zip
    btop
    fastfetch
    bubblewrap
    gnupg
    age
    proton-pass-cli

    # Build toolchain; openssl for mise-compiled runtimes
    gcc
    gnumake
    pkg-config
    openssl
    vips
  ];
}
