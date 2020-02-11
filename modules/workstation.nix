{ pkgs, lib, config, fetchFromGitHub, fetchPypi, ... }:
let
  rke = pkgs.stdenv.mkDerivation rec {
    name = "rke-${version}";
    version = "1.0.2";

    src = pkgs.fetchurl {
      url = "https://github.com/rancher/rke/releases/download/v${version}/rke_linux-amd64";
      sha256 = "0vy89p2hrxr4rba1ijb0xmc99s3avc5hivw27gjxzy48q7s1yj4c";
    };

    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp ${src} $out/bin/rke
      patchelf $out/bin/rke
      chmod 755 $out/bin/rke
    '';
  };

  matterhorn = pkgs.stdenv.mkDerivation rec {
    pname = "matterhorn";
    version = "50200.5.0";

    src = fetchFromGitHub {
      owner = "matterhorn-chat";
      repo = "matterhorn";
      rev = version;
      sha256 = "0x9hniq7b1qdf0375cld2d7pk74pj7k1n4h05pmrzalwg7a2487n";
    };

    isLibrary = false;
    isExecutable = true;
    enableSeparateDataOutput = true;

    executableHaskellDepends = with pkgs.haskellPackages; [
      aeson aspell-pipe async base base-compat brick brick-skylighting
      bytestring cheapskate config-ini connection containers data-clist
      directory filepath gitrev hashable Hclip mattermost-api
      microlens-platform mtl process random semigroups skylighting-core
      stm stm-delay strict temporary text text-zipper time timezone-olson
      timezone-series transformers unix unordered-containers utf8-string
      uuid vector vty word-wrap xdg-basedir
    ];
    testHaskellDepends = with pkgs.haskellPackages; [
      base base-compat brick bytestring cheapskate checkers config-ini
      connection containers directory filepath hashable Hclip
      mattermost-api mattermost-api-qc microlens-platform mtl process
      quickcheck-text semigroups stm strict string-conversions tasty
      tasty-hunit tasty-quickcheck text text-zipper time timezone-olson
      timezone-series transformers Unique unordered-containers uuid
      vector vty xdg-basedir
    ];

    description = "Terminal client for the Mattermost chat system";
    license = lib.licenses.bsd3;
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

  zettelkasten = pkgs.stdenv.mkDerivation rec {
    name = "zettelksten-${version}";
    version = "3.2.7";

    src = pkgs.fetchurl {
      url = "https://github.com/sjPlot/Zettelkasten/releases/download/${version}/Zettelkasten3_linux.zip";
      sha256 = "0mbrg5gr84ijmhpwchgg9xzjc3mh74ap9fsv4s516ark0np670aw";
    };

    buildInputs = with pkgs; [
      unzip
      adoptopenjdk-bin
    ];
  };
 
  wallpaper_sh = pkgs.writeScriptBin "wallpaper.sh"
    (builtins.readFile ../scripts/wallpaper.sh );
  unstableTarball = fetchTarball
    https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports = [
    ./base.nix
    ./i3.nix
  ];

  nixpkgs.config.packageOverrides = super: let self = super.pkgs; in {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
    };

    allowBroken = true;

    stSolarized = lib.overrideDerivation pkgs.st (attrs: rec {
      version = "0.8.2";
      src = (pkgs.fetchgit {
        url = "http://git.suckless.org/st";
        rev = "2b8333f553c14c15398e810353e192eb05938580";
        sha256 = "1awn56cri0x60m4wisaj9kd8qn0ggdqf62232q435p54rm43dwvv";
      });
      patches = [
        (pkgs.fetchurl {
          url = "https://st.suckless.org/patches/scrollback/st-scrollback-20190331-21367a0.diff";
          sha256 = "0hqb04vqiarggw2addh725jpxjg4pn5d4afmssk0kadx247bqx7r";
        })
        (pkgs.fetchurl {
          url = "https://st.suckless.org/patches/scrollback/st-scrollback-mouse-0.8.2.diff";
          sha256 = "1fm1b3yxk9ww2cz0dfm67l42a986ykih37pf5rkhfp9byr8ac0v1";
        })
        (pkgs.fetchurl {
          url = "https://st.suckless.org/patches/solarized/st-no_bold_colors-20170623-b331da5.diff";
          sha256 = "0iaq3wbazpcisys8px71sgy6k12zkhvqi4z47slivqfri48j3qbi";
        })
        (pkgs.fetchurl {
          url = "https://st.suckless.org/patches/solarized/st-solarized-dark-20180411-041912a.diff";
          sha256 = "137q8hs9bhb9kw7z97il77w7378grgp67yzyna1gpshn4s5fimdj";
        })
      ];
      postPatch = ''
        substituteInPlace config.def.h \
          --replace "histsize = 2000" "histsize = 99999"
      '';
    });

   #python3Packages.importlib-metadata = super.python3Packages.importlib-metadata.override {
   #  version = "1.3.0";
   #  
   #  src = fetchPypi {
   #    pname = "importlib_metadata";
   #    version = "1.3.0";
   #    sha256 = "0ibvvqajphwdclbr236gikvyja0ynvqjlix38kvsabgrf0jqafh7";
   #  };
   #};
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

    # ops
    kubectl
    ansible
    terraform
    nixops
    docker_compose
    vagrant
    unstable.linuxPackages_5_4.virtualbox
    rke kail unstable.kubernetes-helm
    #awscli
    #google-cloud-sdk
    #azure-cli

    # network
    wireshark tcpdump
    nmap
    socat
    sshuttle
    ipcalc

    # dev
    gitAndTools.gitflow
    binutils jq
    git-review
    ocl-icd

    # scheme
    #unstable.gambit unstable.gerbil unstable.chez
    #unstable.guile unstable.guile-lib unstable.slibGuile
    #unstable.guile-fibers unstable.guile-lint
    #(import ../packages/guile-charting)
    #microscheme

    # python
    #python3Full python3Packages.virtualenv
    #(pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
    #  flask
    #  ipython
    #  jupyter
    #  pandas
    #  matplotlib
    #]))

    # web, chat & docs
    okular
    libreoffice
    firefox
    thunderbird
    tor-browser-bundle-bin
    mattermost-desktop #matterhorn

    (pkgs.writeScriptBin "wegwerf_firefox_clone"
      (builtins.readFile ../scripts/wegwerf_firefox_clone.sh ))

    # desktop
    arandr
    feh scrot
    termite
    stSolarized

    pavucontrol pasystray
    blueman
    arc-theme
    lxappearance
    xclip
    lxqt.lxqt-policykit
    qt5ct

    # misc
    fuse
    sshfsFuse
    cifs_utils
    google-drive-ocamlfuse
    unstable.enpass
    #zettelkasten
  ];

  nix.daemonIONiceLevel = 7;
  nix.daemonNiceLevel = 19;

  services.emacs.enable = true;
  services.openssh.forwardX11 = true;

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
    extraConfig = ''
      load-module module-switch-on-connect
    '';
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

  boot.kernelPackages = pkgs.unstable.linuxPackages_5_4;
  boot.supportedFilesystems = [ "cifs" ];
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

  services.dbus = {
    socketActivated = true;
    packages = [ pkgs.gnome3.gnome-keyring pkgs.gnome3.gcr ];
  };
  services.gvfs.enable = true;

  services.gnome3 = {
    sushi.enable = true;
    gnome-keyring.enable = true;
  };

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
      victor-mono
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
  hardware.sane = {
    enable = true;
    #netConf = ''
    #  192.168.190.11
    #'';
  };

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

    # Webcam settings
    SUBSYSTEM=="video4linux", KERNEL=="video[0-9]*", RUN="${pkgs.v4l-utils}/bin/v4l2-ctl -d $devnode --set-ctrl=power_line_frequency=1
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

  programs.nm-applet.enable = true;
  programs.dconf.enable = true;
  services.earlyoom.enable = lib.mkDefault true;

  qt5 = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita";
  };

  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt5.qtbase}/lib/qt-5.12.0/plugins/platforms";
    GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];
    GTK_USE_PORTAL = "0";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel";
  };
}
