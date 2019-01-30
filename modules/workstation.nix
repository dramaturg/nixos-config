{ pkgs, lib, config, configName, ... }:
let
  i3Config = (if configName == "pocket" then
    "/etc/nixos/dotfiles/i3/config.pocket"
  else
    "/etc/nixos/dotfiles/i3/config"
  );
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
    version = "0.2.0-rc4";

    src = pkgs.fetchurl {
      url = "https://github.com/rancher/rke/releases/download/v${version}/rke_linux-amd64";
      sha256 = "1d92j3jlk0p0fpvznha68hkz6pw9v8yhkyqhkh5kvp35j71ln6jm";
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
in
{
  environment.systemPackages = with pkgs; [
    shared_mime_info
    wpa_supplicant

    mu
    rofi
    virtmanager
    xiccd
    xsel
    xss-lock

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
    linuxPackages.virtualbox
    freeipmi
    rke

    # network
    speedtest-cli
    wireshark tcpdump
    nmap 
    socat
    wireguard
    wireguard-tools
    sshuttle

    # dev
    gdb gradle
    gitAndTools.gitflow gitAndTools.gitFull git-cola
    man stdman man-pages posix_man_pages
    binutils jq
    git-review
    rustup gcc stack nim
    racket gambit chez chibi chicken gerbil
    guile guile-lib guile-fibers slibGuile guile-lint
    julia
    valgrind
    ocl-icd

    python3Full python3Packages.virtualenv
    (pkgs.python36.withPackages (pythonPackages: with pythonPackages; [
      flask
      pandas
    ]))

    # databases
    dbeaver

    microscheme
    sdcc
    nodejs
    ctags
    nim

    # web, chat & docs
    evince okular
    libreoffice
    firefox
    thunderbird
    skypeforlinux
    tor-browser-bundle-bin
    mattermost-desktop
    (pkgs.writeScriptBin "wegwerf_firefox_clone" (builtins.readFile ../scripts/wegwerf_firefox_clone.sh ))

    # desktop
    arandr
    i3 i3lock dmenu i3-winmenu
    feh scrot
    xautolock
    alacritty termite
    (st.override { conf = builtins.readFile ../dotfiles/st-config.h; })

    pavucontrol pasystray
    blueman
    gnome3.eog gnome3.nautilus
    numix-sx-gtk-theme
    xclip

    # misc
    fuse
    sshfsFuse
    cifs_utils
    enpass
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

  services.flatpak.enable = true;

  virtualisation.libvirtd.enable = true;
  documentation.man.enable = true;

  sound.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio = {
    enable = true;
  };
  
  services.udisks2.enable = true;

  services.avahi = {
    enable = true;
    ipv6 = true;
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

      #mate.enable = true;
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
        #configFile = i3Config;
        configFile = "/etc/nixos/dotfiles/i3/config";
      };
    };
  };

  # QT4/5 global theme
  environment.etc."xdg/Trolltech.conf" = {
    text = ''
      [Qt]
      style=Breeze
    '';
    mode = "444";
  };

  # GTK3 global theme (widget and icon theme)
  environment.etc."xdg/gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-theme-name=Numix-SX-FullDark
    '';
    mode = "444";
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
    openDefaultPorts = true;
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
    #trustedInterfaces = [ "tun0" "tun1" ];
  };

  networking.extraHosts = ''
    77.244.254.19 static.soup.io
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

  home-manager.users.seb = import ./home-desktop.nix;
}
