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
    ctags

    # web & docs
    evince okular
    libreoffice
    firefox chromium
    torbrowser
    thunderbird

    # desktop
    arandr
    i3 i3lock dmenu
    termite rxvt_unicode_with-plugins
    icedtea8_web
    pavucontrol
    networkmanagerapplet
    blueman
    gnome3.eog gnome3.nautilus
    #xautolock
    xorg.xbacklight xorg.xcursorthemes xorg.xdpyinfo
    xorg.xev xorg.xkill
#mate.mate-common mate.mate-session-manager
#mate.mate-settings-daemon mate.mate-utils

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

  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
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
      };
      sessionCommands = ''
          xset s 600 0
          xset r rate 440 50
          xss-lock -l -- i3lock -c b31051 -n &
      '';
    };
    desktopManager = {
	  default = "mate";
	  xterm.enable = false;

      mate.enable = true;
#xfce.enable = true;
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

}
