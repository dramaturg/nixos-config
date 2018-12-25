
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
    kernelModules = [
      "kvm-intel"
    ];
    kernelPackages = pkgs.linuxPackages_4_18;

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
      options snd_hda_intel index=1,0
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
