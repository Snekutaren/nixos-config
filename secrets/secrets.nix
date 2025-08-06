#nixos-config/secrets/secrets.nix
{
  "nixrog-owdious.age".publicKeys = [ (builtins.readFile /home/owdious/.config/age/age.pub) ];
  "nixrog-tellus.age".publicKeys = [ (builtins.readFile /home/owdious/.config/age/age.pub) ];
}