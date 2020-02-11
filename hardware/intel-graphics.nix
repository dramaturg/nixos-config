
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

  boot = {
    extraModprobeConfig = ''
      # intel graphics
      options i915 modeset=1 i915_enable_rc6=7 i915_enable_fbc=1 lvds_downclock=1 # powersave=0
      options bbswitch use_acpi_to_detect_card_state=1
    '';
  };

  services.xserver.videoDrivers = [ "intel" ];

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware = {
    opengl = {
      enable = true;
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
}
