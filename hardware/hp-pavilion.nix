
{ pkgs, lib, config, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
in
{
  imports = [
    ./intel-generic.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  environment.systemPackages = with pkgs; [
    unstable.vulkan-tools
    unstable.clinfo
  ];

  environment.variables.VK_ICD_FILENAMES =
    "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";

  boot.kernelParams = [ "nomodeset" ];
  #boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" "vesa" ];

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        unstable.rocm-opencl-icd
        unstable.rocm-opencl-runtime
        unstable.amdvlk
      ];
    };
  };
}
