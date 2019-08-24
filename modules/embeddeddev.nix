{ pkgs, lib, config, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  services.udev.extraRules = ''
    # stlink
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", SYMLINK+="stlink", MODE="0666"

    # rule for NXP LPC134X-Flash
    SUBSYSTEM=="block", ATTRS{idVendor}=="04cc", ATTRS{idProduct}=="0003", \
        SYMLINK+="lpcflash", MODE="0666"

    # r0cket
    SUBSYSTEM=="block", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="08ac", \
        SYMLINK+="r0ketflash", MODE="0666"

    # stellaris
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1cbe", ATTRS{idProduct}=="00fd", \
        GROUP="users", MODE="0666"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1cbe", ATTRS{idProduct}=="00fd", \
        GROUP="users", MODE="0666", SYMLINK+="ttyStellaris ttyStellaris_$attr{serial}"

    # rad1o
    SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", \
        MODE="0600", OWNER="seb", GROUP="seb", SYMLINK+="rad1o rad1o_$attr{serial}"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", \
        MODE="0600", OWNER="seb", GROUP="seb", SYMLINK+="rad1o rad1o_$attr{serial}"

    # arduino
    SUBSYSTEM=="tty", ATTRS{manufacturer}=="Arduino (www.arduino.cc)", \
        GROUP="users", MODE="0660", SYMLINK+="arduino arduino_$attr{serial}"

    SUBSYSTEMS=="usb", ATTRS{idVendor}=="22b8", ATTRS{idProduct}=="41db", \
        MODE="0666", OWNER="seb"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="22b8", ATTRS{idProduct}=="41de", \
        MODE="0666", OWNER="seb"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="22b8", ATTRS{idProduct}=="428c", \
        MODE="0666", OWNER="seb"

    # buspirate
    # % udevadm info --attribute-walk -n /dev/ttyUSB0  | sed -n '/FTDI/,/serial/p'
    #   ATTRS{manufacturer}=="FTDI"
    #   ATTRS{product}=="FT232R USB UART"
    #   ATTRS{serial}=="A800F315"
    # % udevadm trigger
    # % ./usbreset /dev/bus/usb/00x/00y
    
    SUBSYSTEM=="tty", ATTRS{serial}=="A800F315", GROUP="users", \
        MODE="0660", SYMLINK+="buspirate buspirate_$attr{serial}"

    # stm32 discovery boards, with onboard st/linkv2
    # ie, STM32L, STM32F4.
    # STM32VL has st/linkv1, which is quite different
    
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", \
        MODE:="0666", \
        SYMLINK+="stlinkv2_%n"
    
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
        KERNEL!="sd*", KERNEL!="sg*", KERNEL!="tty*", SUBSYSTEM!="bsg", \
        MODE:="0666", \
        SYMLINK+="stlinkv2_%n"
    
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
        KERNEL=="sd*", MODE:="0666", \
        SYMLINK+="stlinkv2_disk"
    
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
        KERNEL=="sg*", MODE:="0666", \
        SYMLINK+="stlinkv2_raw_scsi"
    
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
        SUBSYSTEM=="bsg", MODE:="0666", \
        SYMLINK+="stlinkv2_block_scsi"
    
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
        KERNEL=="tty*", MODE:="0666", \
        SYMLINK+="stlinkv2_console"

    SUBSYSTEM=="tty", ATTRS{idVendor}=="0d28", ATTRS{idProduct}=="0204", \
        MODE="0664", GROUP="users", SYMLINK+="ttyACM-card10-hdk", ENV{ID_MM_DEVICE_IGNORE}="1"

    SUBSYSTEM=="tty", ATTRS{idVendor}=="0b6a", ATTRS{idProduct}=="003c", \
        MODE="0664", GROUP="users", SYMLINK+="ttyACM-card10-dev", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';

  boot.kernelModules = [
    "ftdi_sio"
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
    };
  };

  environment.systemPackages = with pkgs; [
    microscheme
    sdcc
    openocd
    unstable.platformio

    # FPGA
    arachne-pnr yosys nextpnr
    icestorm

    # electrical
    ngspice
  ];
}
