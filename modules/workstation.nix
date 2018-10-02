{ pkgs, lib, config, ... }:
{

  environment.systemPackages = with pkgs; [
    beancount
    darktable
    fdupes
    gradle
    gthumb
    hplip
    imagemagick7
    ispell
    isync
    jetbrains.datagrip
    jetbrains.idea-community
    libreoffice
    libxml2
    mu
    rofi
    rubber
    shared_mime_info
    silver-searcher
    virtmanager
    wpa_supplicant
    xautolock
    xiccd
    xsel
    xss-lock
    yarn
    zbar

    # shell
    mosh

    # media
    vlc mpv
    glxinfo vdpauinfo libva

    # nix
    nixops

    # ops
    aws kubectl terraform
    ansible
    docker_compose
    linuxPackages.virtualbox
    freeipmi

    # network
    speedtest-cli
    wireshark tcpdump
    nmap 
    socat

    # dev
    gdb gradle
    python3Full python3Packages.virtualenv
    gitAndTools.gitflow gitAndTools.gitFull
    man-pages posix_man_pages
    binutils jq
    git-review
    rustup gcc stack nim
    chicken racket
    valgrind
    nodejs

    # web & docs
    evince okular
    libreoffice
    firefox chromium
    torbrowser

    # desktop
    arandr
    i3 i3lock dmenu
    termite rxvt_unicode_with-plugins
    icedtea8_web
    pavucontrol
    networkmanagerapplet
    blueman
    gnome3.eog gnome3.nautilus
    xorg.xbacklight xorg.xcursorthemes xorg.xdpyinfo
    xorg.xev xorg.xkill

    # misc
    fuse
    sshfsFuse
  ];

  nix.daemonIONiceLevel = 7;
  nix.daemonNiceLevel = 19;

  # boot.initrd.kernelModules = [
  #   "vboxdrv" "vboxnetadp" "vboxnetflt"
  # ];

  # boot.extraModulePackages = [
  #   pkgs.linuxPackages.virtualbox
  # ];

  programs.mosh.enable = true;
  programs.mtr.enable = true;

  virtualisation.libvirtd.enable = true;
  documentation.man.enable = true;

  hardware.pulseaudio.enable = true;

  services.udisks2.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  services.xserver = {
    enable = true;
    layout = "us(altgr-intl)";
    xkbOptions = "ctrl:nocaps,compose:caps,terminate:ctrl_alt_bksp";
    libinput = {
      enable = true;
      naturalScrolling = true;
    };
    displayManager = {
      lightdm = {
        enable = true;
      };
      sessionCommands = ''
          xset s 600 0
          xset r rate 440 50
          xss-lock -l -- i3lock -n &
      '';
    };
    desktopManager = {
      xterm = {
        enable = false;
      };
    };
    windowManager = {
      default = "i3";
      i3 = {
        enable = true;
      };
    };
  };

  services.redshift = {
    enable = true;
    brightness.day = "1";
    brightness.night = "0.6";
    temperature.day = 5500;
    temperature.night = 3400;

    provider = "manual";
    latitude = "54.515";
    longitude = "9.569";
    extraOptions = ["-v"];
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      source-code-pro
      google-fonts
      liberation_ttf
      carlito
      inconsolata
    ];
  };

  services.printing = {
    enable = true;
    drivers = [pkgs.gutenprint];
  };

  services.colord = {
    enable = true;
  };

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  virtualisation.virtualbox.host = {
    enable = true;
    enableHardening = false;
    addNetworkInterface = true;
  };

  services.syncthing = {
    enable = true;
    user = "seb";
    dataDir = "/home/seb/.syncthing";
  };
}
