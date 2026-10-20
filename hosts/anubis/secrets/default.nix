{ ... }:
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  age.secrets = {
    smtp-password.file = ./smtp-password.age;
    immich-cloudflare-token.file = ./cloudflare-token.age;
    immich-database-env.file = ./database-env.age;
    anubis-backup-nas-repository.file = ./nas-repository.age;
    anubis-backup-nas-password.file = ./nas-password.age;
    anubis-backup-offsite-repository.file = ./offsite-repository.age;
    anubis-backup-offsite-password.file = ./offsite-password.age;
    anubis-backup-ssh-key.file = ./backup-ssh-key.age;
  };
}
