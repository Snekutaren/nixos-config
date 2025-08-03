{ config, pkgs, ... }:

let
  resticPasswordFile = config.age.secrets.restic.path;
in {
  systemd.services.restic-backup = {
    description = "Restic Backup Service";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.restic}/bin/restic \
          -r sftp:user@host:/backups \
          backup /etc /home \
          --password-file ${resticPasswordFile}
      '';
    };
  };

  systemd.timers.restic-backup = {
    description = "Run restic backup daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
