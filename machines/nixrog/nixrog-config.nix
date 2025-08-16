# machines/nixrog/nixrog-config.nix
{ config, pkgs, inputs, lib, modulesPath, ... }:
{
  imports = [
    # Hardware profiles
    (modulesPath + "/installer/scan/not-detected.nix")
    # Machine-specific modules
    (inputs.self + "/machines/nixrog/nixrog-disko.nix")
    (inputs.self + "/machines/nixrog/nixrog-network.nix")
    (inputs.self + "/machines/nixrog/nixrog-packages.nix")
    (inputs.self + "/machines/nixrog/nixrog-users.nix")
    # Common system modules
    (inputs.self + "/modules/localization.nix")
    (inputs.self + "/modules/sound.nix")
    #(inputs.self + "/modules/backup.nix")
    (inputs.self + "/modules/hypr/hyprland.nix")
  ];
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-sandbox-paths = [ "/dev/kfd" "/dev/dri/renderD128" ];
      substituters = [
        "http://local.nix-cache:5000?priority=1"
        "https://cache.nixos.org?priority=10"
      ];
      trusted-public-keys = [
        "truenas-nix-cache:F3PBg47BlOWSyBJ/J4dQKHCupuWPBVHeFwnx59uzzi8="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = [ "root" "owdious" "sne" ];
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
      kernelModules = [ "dm-snapshot" "cryptd" "cifs" ];
      luks.devices.cryptroot = {
        device = lib.mkForce "/dev/disk/by-label/NIXOS_LUKS";
        preLVM = true; # Ensure LUKS is opened before LVM
        allowDiscards = true;
        # keyFile = "/etc/luks-keys/cryptroot.key";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    #kernelPackages = pkgs.linuxPackages_6_15;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  disko.enableConfig = true;
  fileSystems = {
    "/" = {
      device = lib.mkForce "/dev/disk/by-label/NIXOS_ROOT";
      fsType = "ext4";
    };
    "/boot" = {
      device = lib.mkForce "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
  hardware = {
    bluetooth.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    xone.enable = true;
    xpad-noone.enable = true;
    amdgpu = {
      amdvlk.enable = false;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };
  };
  services = {
    xserver = {
      videoDrivers = [ "amdgpu" ];
    };
    dbus.enable = true;
    blueman.enable = true;
    upower.enable = true;
    getty.autologinUser = "owdious";
    getty.autologinOnce = true;
    openssh = {
      enable = true;
      ports = [ 6622 ];
    };
  };
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
    pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
    pki.certificates = [ ''
      BeamMP
      =========
              -----BEGIN CERTIFICATE-----
      MIID2jCCA4CgAwIBAgIQGGGnoUA2KVOT6zs+SHkcbzAKBggqhkjOPQQDAjBSMQsw
      CQYDVQQGEwJVUzEZMBcGA1UECgwQQ0xPVURGTEFSRSwgSU5DLjEoMCYGA1UEAwwf
      Q2xvdWRmbGFyZSBUTFMgSXNzdWluZyBFQ0MgQ0EgMTAeFw0yNTA4MDQwNTQ4MjJa
      Fw0yNTExMDIwNTUxMTFaMB0xGzAZBgNVBAMMEmJhY2tlbmQuYmVhbW1wLmNvbTBZ
      MBMGByqGSM49AgEGCCqGSM49AwEHA0IABHDUnkujVG9w9vEph+gOkRKqq+Lzcb0y
      LuNMfax5a0mfANDwPdVVaQXBabrzr1tiEgCvD5H8GERwzCrfNyQNEBKjggJrMIIC
      ZzAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFJzECXJHGBd7pxqJs5I11eEDjP6S
      MGwGCCsGAQUFBwEBBGAwXjA5BggrBgEFBQcwAoYtaHR0cDovL2kuY2YtYi5zc2wu
      Y29tL0Nsb3VkZmxhcmUtVExTLUktRTEuY2VyMCEGCCsGAQUFBzABhhVodHRwOi8v
      by5jZi1iLnNzbC5jb20wHQYDVR0RBBYwFIISYmFja2VuZC5iZWFtbXAuY29tMCMG
      A1UdIAQcMBowCAYGZ4EMAQIBMA4GDCsGAQQBgqkwAQMBATAdBgNVHSUEFjAUBggr
      BgEFBQcDAgYIKwYBBQUHAwEwPgYDVR0fBDcwNTAzoDGgL4YtaHR0cDovL2MuY2Yt
      Yi5zc2wuY29tL0Nsb3VkZmxhcmUtVExTLUktRTEuY3JsMA4GA1UdDwEB/wQEAwIH
      gDAPBgkrBgEEAYLaSywEAgUAMIIBAgYKKwYBBAHWeQIEAgSB8wSB8ADuAHUAEvFO
      NL1TckyEBhnDjz96E/jntWKHiJxtMAWE6+WGJjoAAAGYc6jfAQAABAMARjBEAiBQ
      x2LlwA+bYp0mTF9ygdhtMjRnnr2ygO518RvhP/mdLAIgdVktP9HyHoIjpWgDrIn4
      UQtjGBTp+eJGRU+JdErOdXwAdQDM+w9qhXEJZf6Vm1PO6bJ8IumFXA2XjbapflTA
      /kwNsAAAAZhzqN8WAAAEAwBGMEQCIFU+BgUV9rflnLjGFKmxJLpA6l6OzyjjQdck
      W+iog//sAiAv2dCjd6d6051UsJAnikMVUMXdBEoCXOK54UJeBFsOFzAKBggqhkjO
      PQQDAgNIADBFAiEArH2OXsqyvkAOLeXblf5C8nIW9B8pM+cDqHM4xr5KZ2ECICb+
      3YjyLK7aDbt68lOsU81DcA3AVbRPCHYOBedw19Jv
      -----END CERTIFICATE-----
      -----BEGIN CERTIFICATE-----
      MIIC5DCCAmqgAwIBAgIQLD+iaS9BE707f+W2BLSdTTAKBggqhkjOPQQDAzBPMQsw
      CQYDVQQGEwJVUzEYMBYGA1UECgwPU1NMIENvcnBvcmF0aW9uMSYwJAYDVQQDDB1T
      U0wuY29tIFRMUyBUcmFuc2l0IEVDQyBDQSBSMjAeFw0yMzEwMzExNzE3NDlaFw0z
      MzEwMjgxNzE3NDhaMFIxCzAJBgNVBAYTAlVTMRkwFwYDVQQKDBBDTE9VREZMQVJF
      LCBJTkMuMSgwJgYDVQQDDB9DbG91ZGZsYXJlIFRMUyBJc3N1aW5nIEVDQyBDQSAx
      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEByHHIHytNSzTS+F3JA7hHMDGd2cp
      cY9i3MLTKmE6DJTKc6JwvW50pwKodvd2Qj4RAAy2jSejsVgw5jeh6syt3KOCASMw
      ggEfMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgwFoAUMqLH2FiL/3/APPJV
      aTPszswfvJcwSAYIKwYBBQUHAQEEPDA6MDgGCCsGAQUFBzAChixodHRwOi8vY2Vy
      dC5zc2wuY29tL1NTTC5jb20tVExTLVQtRUNDLVIyLmNlcjARBgNVHSAECjAIMAYG
      BFUdIAAwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMD0GA1UdHwQ2MDQw
      MqAwoC6GLGh0dHA6Ly9jcmxzLnNzbC5jb20vU1NMLmNvbS1UTFMtVC1FQ0MtUjIu
      Y3JsMB0GA1UdDgQWBBScxAlyRxgXe6caibOSNdXhA4z+kjAOBgNVHQ8BAf8EBAMC
      AYYwCgYIKoZIzj0EAwMDaAAwZQIxAL0Sk3RweR6uG1aSHF3JgHQptubP9xoZyUmz
      HSa+SSdY5wTGSx5qAowrLPCpLio2PAIwXQGgYzf5QzD/1Bsu87WrUcIVtLixr5KQ
      wKBaFAyIJ7OOiWgW0HV/NA1UeuSe0zmN
      -----END CERTIFICATE-----
      -----BEGIN CERTIFICATE-----
      MIID0DCCArigAwIBAgIRAK2NLfZGgaDTZEfqqU+ic8EwDQYJKoZIhvcNAQELBQAw
      ezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4G
      A1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQxITAfBgNV
      BAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0yNDA2MjEwMDAwMDBaFw0y
      ODEyMzEyMzU5NTlaME8xCzAJBgNVBAYTAlVTMRgwFgYDVQQKDA9TU0wgQ29ycG9y
      YXRpb24xJjAkBgNVBAMMHVNTTC5jb20gVExTIFRyYW5zaXQgRUNDIENBIFIyMHYw
      EAYHKoZIzj0CAQYFK4EEACIDYgAEZOd9mQNTXJEe6vjYI62hvyziY4nvKGj27dfw
      7Ktorncr5HaXG1Dr21koLW+4NrmrjZfKTCKe7onZAj/9enM6kI0rzC86N4PaDbQt
      RRtzcgllX3ghPeeLZj9H/Qkp1hQPo4IBJzCCASMwHwYDVR0jBBgwFoAUoBEKIz6W
      8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFDKix9hYi/9/wDzyVWkz7M7MH7yXMA4G
      A1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdJQQWMBQGCCsG
      AQUFBwMBBggrBgEFBQcDAjAjBgNVHSAEHDAaMAgGBmeBDAECATAOBgwrBgEEAYKp
      MAEDAQEwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21vZG9jYS5jb20v
      QUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNAYIKwYBBQUHAQEEKDAmMCQGCCsG
      AQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZIhvcNAQELBQAD
      ggEBAB4oL4ChKaKGZVZK8uAXjj8wvFdm45uvhU/t14QeH5bwETeKiQQXBga4/Nyz
      zvpfuoEycantX+tHl/muwpmuHT0Z6IKYoICaMxOIktcTF4qHvxQW2WItHjOglrTj
      qlXJXVL+3HCO60TEloSX8eUGsqfLQkc//z3Lb4gz117+fkDbnPt8+2REq3SCvaAG
      hlh/lWWfHqTAiHed/qqzBSYqqvfjNlhIfXnPnhfAv/PpOUO1PmxCEAEYrg+VoS+O
      +EBd1zkT0V7CfrPpj30cAMs2h+k4pPMwcLuB3Ku4TncBTRyt5K0gbJ3pQ0Rk9Hmu
      wOz5QAZ+2n1q4TlApJzBfwFrCDg=
      -----END CERTIFICATE-----
      ''
    ];
  };
  programs.gamemode.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  #environment.variables = {
  #  QT_QPA_PLATFORMTHEME = "qt5ct";   # Use qt5ct to apply themes
  #  QT_STYLE_OVERRIDE    = "breeze";  # Optional, force a style
  #};
}