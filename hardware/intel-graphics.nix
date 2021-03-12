
{ pkgs, lib, config, ... }:

{
  imports = [
    ./intel-generic.nix
  ];

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
      #driSupport32Bit = true;
    };
  };
}
