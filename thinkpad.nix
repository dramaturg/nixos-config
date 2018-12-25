
{ pkgs, lib, config, ... }:

let
  hardwareTarball = fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in
{
  imports =
    [
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      #<nixos-hardware/lenovo/thinkpad/x250>
      (hardwareTarball + "/lenovo/thinkpad/x250")
      ./modules/laptop.nix
      ./modules/base.nix
    ];


  boot = {
    loader = {
      grub.gfxmodeEfi = "1920x1080";
    };

    kernelModules = [
      "kvm-intel"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "video.use_native_backlight=1"
      "pcie_aspm=force"
      "drm_kms_helper.edid_firmware=edid/1920x1080.bin"
      "video=1920x1080"
      "clocksource=acpi_pm"
      "pci=use_crs"
      "consoleblank=0"
      # colors
      "vt.default_red=0x07,0xdc,0x85,0xb5,0x26,0xd3,0x2a,0xee,0x00,0xcb,0x58,0x65,0x83,0x6c,0x93,0xfd vt.default_grn=0x36,0x32,0x99,0x89,0x8b,0x36,0xa1,0xe8,0x2b,0x4b,0x6e,0x7b,0x94,0x71,0xa1,0xf6 vt.default_blu=0x42,0x2f,0x00,0x00,0xd2,0x82,0x98,0xd5,0x36,0x16,0x75,0x83,0x96,0xc4,0xa1,0xe3"
    ];

    initrd = {
      kernelModules = [
        "fbcon"
        "libata"
      ];
      availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "fbcon"
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

  # networking.hostName = "woodstock";

  services.xserver = {
    videoDrivers = [ "intel" ];
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
  
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
}
