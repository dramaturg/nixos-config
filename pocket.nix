{ pkgs, lib, config, ... }:

let
  configName = "pocket";
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [
      <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      #./modules/mobiledev.nix
      ./modules/embeddeddev.nix
      ./modules/laptop.nix
      ./firmware
    ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
      linux_latest = pkgs.unstable.linux_latest.override {
        extraConfig = ''
          B43_SDIO y
          GPD_POCKET_FAN m

          PMIC_OPREGION y
          CHT_WC_PMIC_OPREGION y
          ACPI_I2C_OPREGION y

          I2C y
          I2C_CHT_WC m

          INTEL_SOC_PMIC_CHTWC y

          EXTCON_INTEL_CHT_WC m

          MATOM y
          I2C_DESIGNWARE_BAYTRAIL y
          POWER_RESET y
          PWM y
          PWM_LPSS m
          PWM_LPSS_PCI m
          PWM_LPSS_PLATFORM m
          PWM_SYSFS y
        '';
      };
    };
  };

  powerManagement = lib.mkForce {
    enable = true;
    powerDownCommands = ''
      rmmod goodix
    '';
    powerUpCommands = ''
      modorobe goodix
    '';

  };

  services.udev = {
    extraRules = let
      script = pkgs.writeShellScriptBin "enable-bluetooth" ''
        modprobe btusb
        echo "0000 0000" > /sys/bus/usb/drivers/btusb/new_id
      '';
     in
       ''
       SUBSYSTEM=="usb", ATTRS{idVendor}=="0000", ATTRS{idProduct}=="0000", RUN+="${script}/bin/enable-bluetooth"
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
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "i915.enable_fbc=1"
      "gpd-pocket-fan.speed_on_ac=0"
    ];

    initrd = {
      kernelModules = [
        "intel_agp"
        "pwm-lpss"
        "pwm-lpss-platform" # for brightness control
        "gpd-pocket-fan"
        "i915"
        "btusb"
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
    extraModprobeConfig = ''
      options i915 enable_fbc=1 enable_rc6=1 modeset=1
      options gpd-pocket-fan temp_limits=40000,40001,40002
    '';
  };

  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };

  fonts.fontconfig.dpi = 200;

  services.xserver =  {
    dpi = 200;
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
      Option "AccelMethod" "sna"
      Option "TearFree"    "true"
      Option "DRI"         "3"
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

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ vaapiIntel vaapiVdpau ];
      driSupport32Bit = true;
      s3tcSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    beignet
  ];
}
