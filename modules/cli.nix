{ pkgs, inputs, ... }:
let
  pass-cli = pkgs.callPackage ../packages/pass-cli.nix { };
in
{
  # The interactive command-line environment: shell, prompt, multiplexer,
  # dotfiles, and the day-to-day terminal toolset.
  programs.zsh.enable = true;
  programs.fzf.keybindings = true;
  programs.fzf.fuzzyCompletion = true;
  users.defaultUserShell = pkgs.zsh;

  environment.sessionVariables = {
    ZI_BIN_DIR = "${pkgs.zinit}";

    # Use GNOME Keyring's Secret Service backend for Proton Pass CLI instead
    # of the session-sensitive kernel keyring backend.
    PROTON_PASS_LINUX_KEYRING = "dbus";
  };

  environment.systemPackages = with pkgs; [
    # Shell, prompt, multiplexer, dotfiles
    zsh
    tmux
    starship
    yadm
    zinit

    # System inspection / misc
    btop
    fastfetch
    bubblewrap
    gnupg
    age
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Modern CLI tooling
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
    mise
    yazi
    silicon
    p7zip

    pass-cli
  ];
}
