{ pkgs, lib, config, ... }:

let
  hardwareTarball = fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in
{
  imports = [
    ./intel-generic.nix
    ./intel-graphics.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    (hardwareTarball + "/dell/xps/13-7390")
  ];

  boot = {
    kernelModules = [ "i8k" ];

    # nix-shell -p systool --run "sudo systool -m i915 -av"
    kernelParams = [
      "i915.enable_guc=2"
      "i915.enable_psr=1"
      "i915.disable_power_well=0"
    ];

    extraModprobeConfig = ''
      options i8k ignore_dmi=1
    '';

    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "rtsx_pci_sdmmc"
    ];
  };

  services.acpid = {
    enable = true;
  };

  services.fwupd = {
    enable = true;
  };

  services.xserver.synaptics = {
    palmDetect = true;
    palmMinWidth = 5;
    palmMinZ = 20;
  };

  hardware = {
    video.hidpi.enable = true;
  };

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
