{ pkgs, lib, config, ... }:

let
  #mesa_with_iris = (pkgs.mesa.override {
  #  galliumDrivers = [
  #    "r300" "r600" "radeonsi" "nouveau" "virgl" "svga" "swrast"
  #    "iris"
  #  ];
  #});

  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
  hardwareTarball = fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in
{
  imports = [
    ./intel-generic.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    (hardwareTarball + "/dell/xps/13-7390")
  ];

  boot = {
    kernelModules = [ "i8k" ];

    #kernelParams = [ "i915.enable_fbc=1" "i915.enable_psr=2" "i915.fastboot=1" "i915.lvds_downclock=1" "drm.vblankoffdelay=1" ];
    #kernelParams = [ "i915.modeset=1" "i915.enable_guc=3" "i915.enable_gvt=0" #xxx "i915.enable_psr=0" "i915.fastboot=1" "i915.enable_fbc=1" ];
    kernelParams = [
      "i915.enable_psr=0"
      "i915.modeset=1"
      "i915.fastboot=1"
      #"i915.enable_guc=3" 
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

  services.tlp = {
    enable = true;
  };

  services.fwupd = {
    enable = true;
  };

  #environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  #environment.variables = {
  #  MESA_LOADER_DRIVER_OVERRIDE = "iris";
  #};

  environment.systemPackages = with unstable.pkgs; [
    beignet
    clinfo
    intel-gpu-tools
    libdrm
    ocl-icd
    opencl-headers
    xorg.libXext
    xorg.libXfixes
  ];

  services.xserver.videoDrivers = [ "intel" ];
  #services.xserver.deviceSection = ''
  #  Option "DRI" "3"
  #  Option "AccelMethod" "uxa"
  #'';

  services.xserver.synaptics = {
    palmDetect = true;
    palmMinWidth = 5;
    palmMinZ = 20;
  };

  hardware = {
    opengl = {
      enable = true;
      #package = mesa_with_iris.drivers;
      #package = (pkgs.mesa.override {
      #  #galliumDrivers = [ "iris" "swrast" "i915" ];
      #  galliumDrivers = [ "iris" "swrast" "virgl" ];
      #}).drivers;
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
      driSupport32Bit = true;
      s3tcSupport = true;
    };
  };

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
