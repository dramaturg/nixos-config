{ pkgs, lib, config, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      #./modules/mobiledev.nix
      ./modules/embeddeddev.nix
      ./modules/laptop.nix
      ./modules/pocket-kernel.nix
      ./modules/base.nix
      ./firmware
    ];

  powerManagement = lib.mkForce {
    enable = true;
    powerDownCommands = ''
      rmmod goodix
    '';
    powerUpCommands = ''
      modorobe goodix
    '';

  };

  services.tlp = {
    extraConfig = ''
      DISK_DEVICES="mmcblk0"
      DISK_IOSCHED="deadline"

      WIFI_PWR_ON_AC=off
      WIFI_PWR_ON_BAT=off
    '';
  };

  boot = {
    kernelParams = [
      # "i915.enable_fbc=1"
      "gpd-pocket-fan.speed_on_ac=0"
    ];
    kernelModules = [
      "kvm-intel"
      "btusb"
    ];
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_gpd_pocket;

    initrd = {
      kernelModules = [
        "pwm-lpss"
        "pwm-lpss-platform" # for brightness control
        "g_serial" # be a serial device via OTG
        "bq24190_charger"
        "i915"
        "fusb302"
      ];
      availableKernelModules = [
        "xhci_pci"
        "dm_mod"
        "btrfs"
        "crc23c"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_acpi"
        "rtsx_pci_sdmmc"
      ];
      #luks.devices = [
      #  {
      #    name = "root";
      #    device = "/dev/mmcblk0p2";
      #    preLVM = true;
      #  }
      #];
    };
  };

  networking.hostName = "zwerg";

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    MOZ_USE_XINPUT2 = "1";
  };

  fonts.fontconfig.dpi = 168;

  services.xserver = {
    dpi = 168;
    displayManager.sessionCommands = ''
      xrdb -merge "${pkgs.writeText "xrdb.conf" ''
        Xcursor.theme: Vanilla-DMZ
        Xcursor.size: 48
      ''}"
    '';
    videoDrivers = [ "intel" ];
    useGlamor = true;
    xrandrHeads = [
      {
        output = "DSI1";
        primary = true;
        monitorConfig = ''
          Option "Rotate" "right"
        '';
      }
    ];
    deviceSection = ''
      Option "TearFree" "true"
    '';
    inputClassSections = [
      ''
        Identifier	  "calibration"
        MatchProduct	"Goodix Capacitive TouchScreen"
        Option  	    "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
      ''
      ''
        Identifier      "GPD trackpoint"
        MatchProduct    "SINO WEALTH Gaming Keyboard"
        MatchIsPointer  "on"
        Driver          "libinput"
        Option          "ScrollButton" "3"
        Option          "ScrollMethod" "button"
        Option          "MiddleEmulation" "True"
        Option          "AccelSpeed" "1"
        Option          "TransformationMatrix" "3 0 0 0 3 0 0 0 1"
      ''
    ];
  };

  environment.systemPackages = with pkgs; [
    beignet
  ];

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    # systemWide = true;
    support32Bit = true;
    extraConfig = ''
    set-card-profile alsa_card.platform-cht-bsw-rt5645 HiFi
    set-default-sink alsa_output.platform-cht-bsw-rt5645.HiFi__hw_chtrt5645_0__sink
    set-sink-port alsa_output.platform-cht-bsw-rt5645.HiFi__hw_chtrt5645_0__sink [Out] Speaker
    '';
    daemon.config = {
      realtime-scheduling = "no";
    };
  };
}
