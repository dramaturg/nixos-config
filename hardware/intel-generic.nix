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
    ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    ksm.enable = true;
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };
  };
}
