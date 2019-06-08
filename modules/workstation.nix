{ pkgs, lib, config, configName, ... }:
let
  i3Config = "/etc/nixos/dotfiles/i3/config.pocket";
  i3-winmenu = pkgs.stdenv.mkDerivation {
    name = "i3-winmenu";
    buildInputs = [
      (pkgs.python36.withPackages (pythonPackages: with pythonPackages; [
        i3-py
      ]))
    ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp ${../scripts/i3-winmenu.py} $out/bin/i3-winmenu
      chmod +x $out/bin/i3-winmenu
    '';
  };

  rke = pkgs.stdenv.mkDerivation rec {
    name = "rke-${version}";
    version = "0.2.3-rc3";

    src = pkgs.fetchurl {
      url = "https://github.com/rancher/rke/releases/download/v${version}/rke_linux-amd64";
      sha256 = "cb97d7c7189b0057e62a009e61a9b894330eec93d27690ae02a19eca027f84b0";
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
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports = [
    ./base.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
    };
  };

  #nixpkgs.config.gnutls.guile = true;

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

    # media
    vlc mpv
    glxinfo vdpauinfo libva
    imagemagick7
    geeqie

    # nix
    nixops
    nixpkgs-lint

    # ops
    aws kubectl terraform
    ansible
    docker_compose
    docker-machine
    unstable.linuxPackages_latest.virtualbox
    rke kail unstable.kubernetes-helm

    # network
    wireshark tcpdump
    nmap
    socat socat2pre
    wireguard
    wireguard-tools
    sshuttle
    ipcalc

    # dev
    gitAndTools.gitflow gitAndTools.gitFull git-cola
    binutils jq
    git-review
    gcc nim
    ocl-icd

    # scheme
    unstable.gambit unstable.gerbil chez
    unstable.guile unstable.guile-lib unstable.slibGuile
    unstable.guile-fibers unstable.guile-lint gnutls
    (import ../packages/guile-charting)

    # python
    python3Full python3Packages.virtualenv
    (pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
      flask
      ipython
      jupyter
      pandas
      matplotlib
    ]))

    # databases
    dbeaver

    microscheme
    sdcc
    nodejs
    ctags global

    # web, chat & docs
    okular
    libreoffice
    firefox
    thunderbird
    tor-browser-bundle-bin
    mattermost-desktop
    (pkgs.writeScriptBin "wegwerf_firefox_clone" (builtins.readFile ../scripts/wegwerf_firefox_clone.sh ))

    # desktop
    arandr
    i3 i3lock dmenu i3-winmenu
    feh scrot
    xautolock
    termite
    (st.override { conf = builtins.readFile ../dotfiles/st-config.h; })

    pavucontrol pasystray
    blueman
    gnome3.eog gnome3.nautilus
    numix-sx-gtk-theme
    xclip
    pinentry_gnome

    # misc
    fuse
    sshfsFuse
    cifs_utils
    unstable.enpass
  ];
  services.flatpak.enable = true;

  nix.daemonIONiceLevel = 7;
  nix.daemonNiceLevel = 19;

  programs.mosh.enable = true;
  programs.mtr.enable = true;

  services.emacs.enable = true;

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

  services.udisks2.enable = true;

  services.avahi = {
    enable = true;
    ipv6 = true;
    nssmdns = true;
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
    displayManager = {
      lightdm = {
        enable = true;
        greeters.gtk = {
          theme.package = pkgs.zuki-themes;
          theme.name = "Zukitre";
        };
      };
      sessionCommands = ''
        export TERMINAL=termite

        xset s 600 0
        xset r rate 440 50
        xss-lock -l -- i3lock -c b31051 -n &
        ${pkgs.networkmanagerapplet}/bin/nm-applet &
      '';
    };
    desktopManager = {
      default = "xfce";
      xterm.enable = false;

      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager = {
      default = "i3";
      i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3lock
          i3status
          i3-winmenu
        ];
        configFile = i3Config;
        #configFile = "/etc/nixos/dotfiles/i3/config";
      };
    };
  };

  services.dbus.socketActivated = true;

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
    enableFontDir = true;
    enableDefaultFonts = true;

    fonts = with pkgs; [
      comic-relief
      fira
      fira-code
      nerdfonts
      carlito
      corefonts
      dejavu_fonts
      google-fonts
      inconsolata
      iosevka
      liberation_ttf
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

  networking = {
    networkmanager = {
      enable = true;
      packages = [
        pkgs.networkmanager-openvpn
        pkgs.networkmanagerapplet
        pkgs.networkmanager_dmenu
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 22 ];
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
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.unclutter}/bin/unclutter";
  };

  systemd.user.services."autocutsel" = {
    enable = true;
    description = "AutoCutSel";
    wantedBy = [ "default.target" ];
    serviceConfig.Type = "forking";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStartPre = "${pkgs.autocutsel}/bin/autocutsel -fork";
    serviceConfig.ExecStart = "${pkgs.autocutsel}/bin/autocutsel -selection PRIMARY -fork";
  };

  systemd.user.services."xautolock" = {
    enable = true;
    description = "Automatically lock X screen";
    wantedBy = [ "default.target" ];
    serviceConfig.Type = "simple";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 10;
    serviceConfig.ExecStart = "${pkgs.xautolock}/bin/xautolock -time 15 -locker \"i3lock -c b31051 -t\"";
    serviceConfig.Environment = "DISPLAY=:0 XAUTHORITY=/home/seb/.Xauthority";
  };

  #home-manager.users.seb = import ./home-desktop.nix;
}
