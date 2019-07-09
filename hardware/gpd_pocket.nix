{ pkgs, lib, config, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
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
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelPatches =  [ {
      name = "pocket";
      patch = null;
      extraConfig = ''
        B43_SDIO y
        GPD_POCKET_FAN m

        MATOM y
        GENERIC_CPU n

        CHARGER_MAX14577 m
        GPIO_WHISKEY_COVE m

        CMA y
        CMA_AREAS 7

        PMIC_OPREGION y
        ACPI_I2C_OPREGION y

        I2C y

        I2C_DESIGNWARE_BAYTRAIL y
        POWER_RESET y
        PWM y
        PWM_LPSS y
        PWM_LPSS_PCI y
        PWM_LPSS_PLATFORM y
        PWM_SYSFS y
        LEDS_PWM m

        BACKLIGHT_LP855X m
        BACKLIGHT_PWM m

        6LOWPAN_DEBUGFS y
        9P_FS_SECURITY y

        BATMAN_ADV_MCAST y
        BATMAN_ADV_NC y

        BCMA_DRIVER_GPIO y
        BCMA_DRIVER_GMAC_CMN y

        BLK_CGROUP_IOLATENCY y
        CGROUP_PERF y

        BT_HCIBTUSB m
        BT_LEDS y

        BXT_WC_PMIC_OPREGION y
      '';
    } ];

    kernelParams = [
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
      "gpd-pocket-fan.speed_on_ac=0"
    ];

    initrd = {
      kernelModules = [
        "intel_agp"
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

  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };
}
