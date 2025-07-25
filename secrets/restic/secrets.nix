let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBRa4VznvvHBlNiXhY5VINNPrXKzLXAVCdXjgbF1Oea snekutaren@gmail.com"; # Your SSH public key
in {
  "restic-password.age".publicKeys = [ user ];
  "restic-repo.age".publicKeys = [ user ];
  "restic-sftp.age".publicKeys = [ user ];
}