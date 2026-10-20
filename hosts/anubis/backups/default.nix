{
  config,
  lib,
  pkgs,
  ...
}:
let
  secrets = config.age.secrets;
  compose = import ../immich/compose.nix { inherit config pkgs; };
  sshConfig = pkgs.writeText "anubis-backup-ssh" ''
    Host *
      IdentityFile ${secrets.anubis-backup-ssh-key.path}
      IdentitiesOnly yes
      BatchMode yes
      StrictHostKeyChecking yes
      UserKnownHostsFile ${./known_hosts}
      AddressFamily inet
      ConnectTimeout 30
      ServerAliveInterval 30
      ServerAliveCountMax 3
  '';
  nas = {
    repositoryFile = secrets.anubis-backup-nas-repository.path;
    passwordFile = secrets.anubis-backup-nas-password.path;
    extraOptions = [ "sftp.args='-F ${sshConfig}'" ];
    timerConfig = null;
  };
  immich = pkgs.writeShellApplication {
    name = "immich-backup";
    runtimeInputs = [
      compose
      pkgs.coreutils
    ];
    text = builtins.readFile ./immich.sh;
  };
in
{
  systemd.tmpfiles.rules = [ "d /var/lib/anubis-backup 0700 root root -" ];

  services.restic.backups = {
    immich = nas // {
      paths = [
        "/var/lib/immich/data"
        secrets.immich-database-env.path
        secrets.immich-cloudflare-token.path
        "/var/lib/immich/traefik"
        "/var/lib/anubis-backup/immich.sql"
      ];
      extraBackupArgs = [ "--tag immich" ];
      backupPrepareCommand = "${lib.getExe immich} prepare";
      backupCleanupCommand = "${lib.getExe immich} cleanup";
    };
    personal = nas // {
      paths = [
        "/home/hschne"
        "/var/lib/tailscale"
        "/etc/ssh"
      ];
      exclude = [
        "/home/hschne/Pictures/Photos"
        "/home/hschne/.cache"
        "/home/hschne/.local/share/Trash"
        "/home/hschne/.ssh/agent"
        "**/.stfolder"
      ];
      extraBackupArgs = [ "--tag personal" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };
    nas-maintenance = nas // {
      pruneOpts = [
        "--group-by host,tags"
        "--keep-daily 14"
        "--keep-weekly 8"
        "--keep-monthly 6"
      ];
      checkOpts = [ "--read-data-subset=5%" ];
      timerConfig = {
        OnCalendar = "Mon *-*-* 15:00:00";
        Persistent = true;
      };
    };
    offsite = {
      repositoryFile = secrets.anubis-backup-offsite-repository.path;
      passwordFile = secrets.anubis-backup-offsite-password.path;
      extraOptions = nas.extraOptions;
      # Copy weekly checkpoints without reimporting history already expired offsite.
      backupPrepareCommand = ''
        ${lib.getExe pkgs.restic} -o ${lib.escapeShellArg "sftp.args=-F ${sshConfig}"} copy --tag immich latest &&
        ${lib.getExe pkgs.restic} -o ${lib.escapeShellArg "sftp.args=-F ${sshConfig}"} copy --tag personal latest
      '';
      pruneOpts = [
        "--group-by host,tags"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      checkOpts = [ "--read-data-subset=5%" ];
      timerConfig = {
        OnCalendar = "Sun *-*-* 06:00:00";
        Persistent = true;
      };
    };
  };

  systemd.services = {
    restic-backups-immich = {
      requires = [ "docker.service" ];
      after = [ "docker.service" ];
      environment = {
        IMMICH_DUMP_FILE = "/var/lib/anubis-backup/immich.sql";
      };
      serviceConfig = {
        TimeoutStartSec = "12h";
        TimeoutStopSec = "15m";
      };
    };
    restic-backups-personal = {
      wants = [ "restic-backups-immich.service" ];
      after = [ "restic-backups-immich.service" ];
      serviceConfig.TimeoutStartSec = "12h";
    };
    restic-backups-nas-maintenance = {
      after = [
        "restic-backups-personal.service"
        "restic-backups-offsite.service"
      ];
      serviceConfig.TimeoutStartSec = "2d";
    };
    restic-backups-offsite = {
      after = [ "restic-backups-personal.service" ];
      environment = {
        RESTIC_FROM_REPOSITORY_FILE = secrets.anubis-backup-nas-repository.path;
        RESTIC_FROM_PASSWORD_FILE = secrets.anubis-backup-nas-password.path;
      };
      serviceConfig.TimeoutStartSec = "2d";
    };
  };

}
