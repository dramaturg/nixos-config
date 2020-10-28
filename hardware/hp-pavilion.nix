
{ pkgs, lib, config, ... }:

{
  imports = [
    ./intel-generic.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.kernelParams = [ "nomodeset" ];
  #boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" "vesa" ];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  #hardware = {
  #  opengl = {
  #    enable = true;
  #    extraPackages = with pkgs; [
  #      rocm-opencl-icd
  #      amdvlk
  #    ];
  #  };
}
