{ pkgs, lib, config, ... }:

{
  imports = [
    ./intel-generic.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  environment.systemPackages = with pkgs; [
    beignet
    ocl-icd
    intel-ocl
    libva
  ];

  boot = {
    extraModulePackages = with pkgs.linuxPackages_hardened; [ it87 ];    
    kernelModules = [
      "kvm-intel"
      "coretemp"
      "it87"
    ];
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
        intel-ocl
      ];
      s3tcSupport = true;
    };
  };
}
