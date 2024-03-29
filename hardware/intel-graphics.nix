{ pkgs, lib, config, ... }:

{
  imports = [
    ./intel-generic.nix
  ];

  boot = {
    kernelModules = [ "i915" ];
    initrd.availableKernelModules = [ "i915" ];
  };

  environment.systemPackages = with pkgs; [
    beignet
    clinfo
    intel-gpu-tools
    libdrm
    ocl-icd
    opencl-headers
    xorg.libXext
    xorg.libXfixes
  ];

  services.xserver.videoDrivers = [ "intel" "vesa" ];

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
        intel-compute-runtime
      ];
    };
  };
}
