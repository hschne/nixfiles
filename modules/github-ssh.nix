{ lib, ... }:
let
  secretFile = ../secrets/github-ssh-hschne.age;
in
{
  age.identityPaths = [
    "/home/hschne/.ssh/nixfiles"
  ];

  age.secrets = lib.mkIf (builtins.pathExists secretFile) {
    github-ssh-hschne = {
      file = secretFile;
      path = "/home/hschne/.ssh/hschne@github.com";
      owner = "hschne";
      group = "users";
      mode = "600";
    };
  };
}
