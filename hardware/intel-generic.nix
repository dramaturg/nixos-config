
{ pkgs, lib, config, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.configurationLimit = 10;
  };

  nix = {
    binaryCaches = [
      "https://cache.nixos.org/"
      "https://hie-nix.cachix.org"
    ];
    binaryCachePublicKeys = [
      "hie-nix.cachix.org-1:EjBSHzF6VmDnzqlldGXbi0RM3HdjfTU3yDRi9Pd0jTY="
    ];
  };

  hardware = {
    ksm.enable = true;
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };
  };
}
