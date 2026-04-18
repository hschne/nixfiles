{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Vienna";

  users.users.hschne = {
    isNormalUser = true;
    description = "Hans Schnedlitz";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT22cRCeqhk1u60725JZGb16dHpxrK5PeskeprGEcoA hschne@anubis"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.sessionVariables = {
    ZI_BIN_DIR = "${pkgs.zinit}/share/zinit";
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    neovim
    htop
    wget
    rsync
    unzip
    zip
    gzip
    btop
    fastfetch
    tree
    less
    file
    gnupg
    age
    zsh
    tmux
    starship
    yadm
    zinit
    eza
    bat
    fd
    ripgrep
    fzf
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
  ];
}
