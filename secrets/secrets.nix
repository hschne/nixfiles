let
  nixfiles = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRBGVKHo6oW3HNJZbl4fdXG4NHnuy576zzzwwiMZ+vm nixfiles";
  anubis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDi/yXUdJrzS2P5sfuHIOIeuAg0Pg1VUgLLcPvONZkuL root@nixos";
in {
  "github-ssh-hschne.age".publicKeys = [
    nixfiles
    anubis
  ];
}
