{ config, pkgs, lib, ... }:

{
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
 
  # !!! This is only for ARMv6 / ARMv7. Don't enable this on AArch64, cache.nixos.org works there.
  nix.binaryCaches = lib.mkForce [ "http://nixos-arm.dezgeg.me/channel" ];
  nix.binaryCachePublicKeys = [ "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%" ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  nix.extraOptions = ''
    gc-keep-derivations = false
  '';

  services.journald.extraConfig = "SystemMaxUse=10M";


  security.apparmor.enable = true;
  virtualisation.lxc = {
    enable = true;
    usernetConfig = ''
      lukas veth lxcbr0 10
    '';
  };

}