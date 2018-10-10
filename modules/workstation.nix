{ pkgs, lib, config, ... }:
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

    # media
    vlc mpv
    glxinfo vdpauinfo libva
    imagemagick7

    # nix
    nixops

    # ops
    aws kubectl terraform
    ansible
    docker_compose
    docker-machine
    linuxPackages.virtualbox
    freeipmi

    # network
    speedtest-cli
    wireshark tcpdump
    nmap 
    socat
    wireguard
    wireguard-tools

    # dev
    gdb gradle
    python3Full python3Packages.virtualenv
    gitAndTools.gitflow gitAndTools.gitFull git-cola
    man stdman man-pages posix_man_pages
    binutils jq
    git-review
    rustup gcc stack nim
    chicken racket
    valgrind
    nodejs
    ctags

    # web & docs
    evince okular
    libreoffice
    firefox chromium
    thunderbird

    # desktop
    arandr
    i3 i3lock dmenu
    feh scrot
    xautolock
    alacritty termite rxvt_unicode_with-plugins
    icedtea8_web
    pavucontrol pasystray
    networkmanagerapplet
    networkmanager_dmenu
    networkmanager_iodine
    networkmanager_openvpn
    blueman
    gnome3.eog gnome3.nautilus
    xorg.xbacklight xorg.xcursorthemes xorg.xdpyinfo
    xorg.xev xorg.xkill
    numix-sx-gtk-theme

    # misc
    fuse
    sshfsFuse
    cifs_utils
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

  sound.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
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
#        autoLogin = {
#          enable = true;
#          user = "seb";
#        };
      };
      sessionCommands = ''
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
        ];
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
      carlito
      corefonts
      dejavu_fonts
      google-fonts
      inconsolata
      liberation_ttf
      source-code-pro
      terminus_font
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
