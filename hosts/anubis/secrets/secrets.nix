let
  anubis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrdlXjZf6uyTGysUznBCM8fIQW1FRgH9Z5c5/bqnxFp root@anubis";
  recovery = "age1d8wqnyj7hn27e4k5kwk8l9kalqnkqh6qw6yrwaf37cdg7d9muc4qgxrd5d";
  recipients = [
    anubis
    recovery
  ];
in
{
  "smtp-password.age".publicKeys = recipients;
  "cloudflare-token.age".publicKeys = recipients;
  "database-env.age".publicKeys = recipients;
  "nas-repository.age".publicKeys = recipients;
  "nas-password.age".publicKeys = recipients;
  "offsite-repository.age".publicKeys = recipients;
  "offsite-password.age".publicKeys = recipients;
  "backup-ssh-key.age".publicKeys = recipients;
}
