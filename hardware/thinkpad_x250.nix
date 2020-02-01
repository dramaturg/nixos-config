{ pkgs, lib, config, ... }:

let
  hardwareTarball = fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in
{
  imports = [
    ./intel-generic.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    (hardwareTarball + "/lenovo/thinkpad/x250")
  ];

  environment.systemPackages = with pkgs; [
    beignet
    ocl-icd
    intel-ocl
  ];

  boot = {
    kernelModules = [
      "kvm-intel"
    ];
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

  powerManagement = {
    powerUpCommands = ''
      echo min_power > /sys/class/scsi_host/host0/link_power_management_policy
      echo min_power > /sys/class/scsi_host/host1/link_power_management_policy
      echo min_power > /sys/class/scsi_host/host2/link_power_management_policy
      echo auto > /sys/bus/usb/devices/2-4/power/control
      echo auto > /sys/bus/pci/devices/0000:00:16.0/power/control
      echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
    '';
  };

  hardware.trackpoint = {
    enable = true;
    sensitivity = 220;
    speed = 0;
    emulateWheel = true;
  };

  # clean up efi flash on shutdown
  systemd.services."cleanup-efivars" = {
    enable = true;
    description = "clean up efi flash on shutdown";
    after = [ "final.target" ];
    wantedBy = [ "final.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = "${pkgs.findutils}/bin/find /sys/firmware/efi/efivars -name dump-\* -ctime +7 -delete";
    unitConfig.DefaultDependencies = "no";
  };
}
