# secrets/secrets.nix
let
  nixrogKey = "age13vfwxc02qv6yw4fchu7hjrpg3y6d5x72jxm5afujquqf8tncrv0sjw07af"; # From keygen output
in {
  "nixrog-tellus.age".publicKeys = [ nixrogKey ];
}