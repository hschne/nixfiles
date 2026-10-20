{
  config,
  lib,
  pkgs,
  ...
}:
let
  sender = "hans.schnedlitz@gmail.com";
  email = pkgs.writeShellApplication {
    name = "failure-email";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
      pkgs.msmtp
    ];
    text = builtins.readFile ./email.sh;
  };
in
{
  programs.msmtp = {
    enable = true;
    setSendmail = false;
    defaults = {
      tls = true;
      tls_starttls = true;
      tls_trust_file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      timeout = 30;
    };
    accounts.default = {
      host = "smtp.gmail.com";
      port = 587;
      auth = true;
      user = sender;
      from = sender;
      passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.smtp-password.path}";
    };
  };

  systemd.services = {
    "failure-email@" = {
      description = "Email notification for failed service %i";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        ALERT_FROM = sender;
        ALERT_TO = "hello@hansschnedlitz.com";
        ALERT_HOST = config.networking.hostName;
      };
      unitConfig = {
        StartLimitIntervalSec = "10min";
        StartLimitBurst = 3;
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe email} %i";
        Restart = "on-failure";
        RestartSec = "1min";
        TimeoutStartSec = "2min";
        UMask = "0077";
      };
    };
    restic-backups-immich.onFailure = [ "failure-email@%n.service" ];
    restic-backups-personal.onFailure = [ "failure-email@%n.service" ];
    restic-backups-offsite.onFailure = [ "failure-email@%n.service" ];
    restic-backups-nas-maintenance.onFailure = [ "failure-email@%n.service" ];
  };
}
