{ pkgs, lib, config, ... }:
let
  rke = pkgs.stdenv.mkDerivation rec {
    name = "rke-${version}";
    version = "0.2.6";

    src = pkgs.fetchurl {
      url = "https://github.com/rancher/rke/releases/download/v${version}/rke_linux-amd64";
      sha256 = "06anmvfcbb9dh6291pjvgwqq40fs65lmcp1rhcb7rhr86kyy16bn";
    };

    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp ${src} $out/bin/rke
      patchelf $out/bin/rke
      chmod 755 $out/bin/rke
    '';
  };

  vpaste = pkgs.writeScriptBin "vpaste" ''
    #!${pkgs.bash}/bin/bash

    uri="http://vpaste.net/"

    if [ -f "$1" ]; then
        out=$(curl -s -F "text=<$1" "$uri?$2")
    else
        out=$(curl -s -F 'text=<-' "$uri?$1")
    fi

    echo "$out"

    if [ -x "`which xclip 2>/dev/null`" -a "$DISPLAY" ]; then
        echo -n "$out" | xclip -i -selection primary
        echo -n "$out" | xclip -i -selection clipboard
    fi
  '';

  wallpaper_sh = pkgs.writeScriptBin "wallpaper.sh"
    (builtins.readFile ../scripts/wallpaper.sh );
  unstableTarball = fetchTarball
    https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports = [
    ./base.nix
    ./i3.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
    };
    allowBroken = true;
  };

  environment.systemPackages = with pkgs; [
    shared_mime_info

    mu
    rofi
    xiccd
    xsel
    xss-lock
    man stdman man-pages posix_man_pages

    # shell
    mosh
    fdupes
    vpaste
    nnn

    # media
    vlc mpv
    vdpauinfo libva
    geeqie

    # nix
    nixops
    nixpkgs-lint

    # ops
    aws kubectl
    ansible
    docker_compose
    docker-machine
    vagrant
    unstable.linuxPackages_latest.virtualbox
    rke kail unstable.kubernetes-helm

    # network
    wireshark tcpdump
    nmap
    socat
    wireguard
    wireguard-tools
    sshuttle
    ipcalc

    # dev
    gitAndTools.gitflow
    binutils jq
    git-review
    ocl-icd

    # scheme
    unstable.gambit unstable.gerbil unstable.chez
    unstable.guile unstable.guile-lib unstable.slibGuile
    unstable.guile-fibers unstable.guile-lint
    (import ../packages/guile-charting)
    microscheme

    # python
    python3Full python3Packages.virtualenv
    (pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
      flask
      ipython
      jupyter
      pandas
      matplotlib
    ]))

    # web, chat & docs
    okular
    libreoffice
    firefox
    thunderbird
    tor-browser-bundle-bin
    mattermost-desktop
    (pkgs.writeScriptBin "wegwerf_firefox_clone"
      (builtins.readFile ../scripts/wegwerf_firefox_clone.sh ))

    # desktop
    arandr
    feh scrot
    termite

    pavucontrol pasystray
    blueman
    arc-theme
    lxappearance
    xclip
    pinentry_gnome
    lxqt.lxqt-policykit
    qt5ct

    # misc
    fuse
    sshfsFuse
    cifs_utils
    unstable.enpass
  ];

  nix.daemonIONiceLevel = 7;
  nix.daemonNiceLevel = 19;

  services.emacs.enable = true;

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "daily";
    };
  };
  virtualisation.libvirtd.enable = true;
  documentation.man.enable = true;

  sound.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio = {
    enable = true;
    zeroconf = {
        discovery.enable = false;
        publish.enable = false;
    };
  };

  # wireshark capturing
  users.groups.wireshark.members = [ "seb" ];
  security.wrappers.dumpcap = {
    source = "${pkgs.wireshark}/bin/dumpcap";
    permissions = "u+xs,g+x";
    owner = "root";
    group = "wireshark";
  };

  services.udisks2.enable = true;

  services.avahi = {
    enable = true;
    ipv6 = true;
    nssmdns = true;
    publish = {
      enable = false;
      userServices = true;
    };
  };

  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;
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
  };

  services.dbus.socketActivated = true;
  services.gvfs.enable = true;

  services.redshift = {
    enable = true;
    brightness.day = "1";
    brightness.night = "0.6";
    temperature.day = 5500;
    temperature.night = 3400;

    extraOptions = ["-v"];
  };
  location = {
    provider = "manual";
    latitude = 54.515;
    longitude = 9.569;
  };

  fonts = {
    enableFontDir = true;
    enableDefaultFonts = true;

    fonts = with pkgs; [
      carlito
      comic-relief
      corefonts
      dejavu_fonts
      fira
      fira-code
      google-fonts
      inconsolata
      iosevka
      liberation_ttf
      nerdfonts
      noto-fonts-cjk
      source-code-pro
      terminus_font
    ];
    fontconfig = {
      enable = true;
      useEmbeddedBitmaps = true;
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font Mono" ];
        sansSerif = [ "Roboto" ];
        serif     = [ "Roboto Slab" ];
      };
    };
  };

  i18n.consoleFont = "latarcyrheb-sun32";

  services.printing = {
    enable = true;
    drivers = [pkgs.gutenprint];
  };
  hardware.sane.enable = true;

  services.colord = {
    enable = true;
  };

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  users.groups.vboxusers.members = [ "seb" ];
  boot.kernelModules = [ "vboxdrv" ];
  virtualisation.virtualbox.host = {
    enable = true;
    enableHardening = false;
    addNetworkInterface = true;
    package = pkgs.unstable.virtualbox;
  };

  services.syncthing = {
    enable = true;
    user = "seb";
    dataDir = "/home/seb/.syncthing";
    openDefaultPorts = true;
    package = pkgs.unstable.syncthing;
  };

  networking.firewall = {
    allowedTCPPorts = [
      22
      8010 # chromecast with VLC
    ];
  };

  services.udev.packages = with pkgs; [
      libu2f-host yubikey-personalization
  ];
  services.udev.extraRules = ''
    # Access to /dev/bus/usb/* devices. Needed for virt-manager USB
    # redirection.
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0664", GROUP="wheel"

    # Allow users in group 'usbmon' to do USB tracing, e.g. in Wireshark
    # (after 'modprobe usbmon').
    SUBSYSTEM=="usbmon", GROUP="usbmon", MODE="640"
  '';

  systemd.user.services."unclutter" = {
    enable = true;
    description = "hide cursor after X seconds idle";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 2;
      ExecStart = "${pkgs.unclutter}/bin/unclutter";
    };
  };

  systemd.user.services."autocutsel" = {
    enable = true;
    description = "AutoCutSel";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "forking";
      Restart = "always";
      RestartSec = 2;
      ExecStartPre = "${pkgs.autocutsel}/bin/autocutsel -fork";
      ExecStart = "${pkgs.autocutsel}/bin/autocutsel -selection PRIMARY -fork";
    };
  };

  systemd.user.services."wallpaper" = {
    enable = true;
    path = with pkgs; [ nix ];
    description = "Rotate Wallpapers";
    wantedBy = [ "default.target" ];
    environment = {
      DISPLAY = ":0";
      XAUTHORITY = "/home/seb/.Xauthority";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
      ExecStart = "${wallpaper_sh}/bin/wallpaper.sh";
    };
  };

  systemd.user.services."xautolock" = {
    enable = true;
    description = "Automatically lock X screen";
    wantedBy = [ "default.target" ];
    environment = {
      DISPLAY = ":0";
      XAUTHORITY = "/home/seb/.Xauthority";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
      ExecStart = "${pkgs.xautolock}/bin/xautolock -time 15 -locker \"i3lock -c b31051 -t\"";
    };
  };

  home-manager.users.seb = import ./home-desktop.nix;

  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt5.qtbase}/lib/qt-5.12.0/plugins/platforms";
    GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];
  };
}
