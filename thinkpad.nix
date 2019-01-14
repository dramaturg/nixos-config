
{ pkgs, lib, config, ... }:

let
  hardwareTarball = fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in
{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      (hardwareTarball + "/lenovo/thinkpad/x250")
      ./modules/embeddeddev.nix
      ./modules/laptop.nix
      ./modules/base.nix
    ];


  boot = {
    kernelModules = [
      "kvm-intel"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "pcie_aspm=force"
      "clocksource=acpi_pm"
      "pci=use_crs"
      "consoleblank=0"
    ];

    initrd = {
      kernelModules = [
        "libata"
      ];
      availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "btrfs"
        "crc23c"
        "usbhid"
      ];
    };

    extraModprobeConfig = ''
      # thinkpad acpi
      options thinkpad_acpi fan_control=1

      # intel graphics
      options i915 modeset=1 i915_enable_rc6=7 i915_enable_fbc=1 lvds_downclock=1 # powersave=0
      options bbswitch use_acpi_to_detect_card_state=1

      # sound
      #options snd_hda_intel index=1,0

      # intel wifi
      options iwlwifi 11n_disable=8
      iwlwifi.power_save=Y
      iwldvm.force_cam=N
    '';
  };

  # powerManagement.scsiLinkPolicy = "max_performance";

  nix.binaryCaches = [ "https://hydra.mayflower.de/" "https://cache.nixos.org/" ];
  nix.binaryCachePublicKeys = [
    "hydra.mayflower.de:9knPU2SJ2xyI0KTJjtUKOGUVdR2/3cOB4VNDQThcfaY=" 
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
  ];

  environment.systemPackages = with pkgs; [
    beignet
    steam
    calibre
  ];

  services.xserver = {
    videoDrivers = [ "intel" ];
  };

  hardware = {
    opengl = {
      extraPackages = with pkgs; [ vaapiIntel vaapiVdpau ];
      driSupport32Bit = true;
      s3tcSupport = true;
    };
  };

  services.thermald.enable = true;
  #services.thinkfan.enable = true;

  services.acpid = {
    enable = true;
#    lidEventCommands = ''
#      if grep -q closed /proc/acpi/button/lid/LID/state; then
#        date >> /tmp/i3lock.log
#        DISPLAY=":0.0" XAUTHORITY=/home/seb/.Xauthority ${pkgs.i3lock}/bin/i3lock &>> /tmp/i3lock.log
#      fi
#    '';
  };

  services.tlp = {
    enable = true;
    extraConfig = ''
      START_CHARGE_THRESH_BAT0=75
      STOP_CHARGE_THRESH_BAT0=90
      START_CHARGE_THRESH_BAT1=75
      STOP_CHARGE_THRESH_BAT1=90
    '';
  };

  hardware.trackpoint = {
    enable = true;
    sensitivity = 220;
    speed = 0;
    emulateWheel = true;
  };
}
