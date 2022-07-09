{ pkgs, lib, config, fetchFromGitHub, fetchPypi, ... }:
let
  damdamdammm = pkgs.writeScriptBin "damdamdammm" ''
    #!${pkgs.bash}/bin/bash

    ${pkgs.v4l-utils}/bin/v4l2-ctl -d /dev/video2 --set-ctrl=zoom_absolute=3
    sleep 0.3
    ${pkgs.v4l-utils}/bin/v4l2-ctl -d /dev/video2 --set-ctrl=zoom_absolute=1
    sleep 0.3
    ${pkgs.v4l-utils}/bin/v4l2-ctl -d /dev/video2 --set-ctrl=zoom_absolute=5

    sleep 1.5
    ${pkgs.v4l-utils}/bin/v4l2-ctl -d /dev/video2 --set-ctrl=zoom_absolute=1
  '';

  myxclip = pkgs.writeScriptBin "xclip" ''
    #!${pkgs.bash}/bin/bash

    # if stdin is not a terminal, strip out all the escape code crud
    if [ \! -t 0 ] ; then
        sed 's/\x1b\[[0-9;]*m//g'        |\
        sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' |\
        sed 's/\x1b\[[0-9;]*[mGKFH]//g'  |\
        ${pkgs.xclip}/bin/xclip $@
        exit $?
    fi

    exec ${pkgs.xclip}/bin/xclip $@
  '';

  stripescapecodes = pkgs.writeScriptBin "stripescapecodes" ''
    #!${pkgs.bash}/bin/bash

    # strip out all the escape code crud
    sed 's/\x1b\[[0-9;]*m//g'        |\
    sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' |\
    sed 's/\x1b\[[0-9;]*[mGKFH]//g'
  '';

  wallpaper_sh = pkgs.writeScriptBin "wallpaper.sh"
    (builtins.readFile ../scripts/wallpaper.sh);
  unstableTarball = fetchTarball
    https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports = [
    ./base.nix
    ./i3.nix
    ./embeddeddev.nix
  ];

  nixpkgs = {
    config.packageOverrides = super:
      let self = super.pkgs;
      in {
        unstable = import unstableTarball { config = config.nixpkgs.config; };
        allowBroken = true;
      };
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.noXlibs = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    shared-mime-info

    mu
    rofi
    xiccd
    xsel
    xss-lock
    man
    stdman
    man-pages
    posix_man_pages
    alacritty

    # shell
    mosh
    fdupes
    damdamdammm
    nnn
    tmux-cssh
    direnv

    # media
    vlc
    mpv
    vdpauinfo
    libva
    geeqie

    # ops
    kubectl
    kubectx
    ansible
    vagrant
    #linuxPackages_latest.virtualbox

    # network
    wireshark
    tcpdump
    nmap
    socat
    sshuttle
    ipcalc

    # dev
    gitAndTools.gitflow
    gitAndTools.diff-so-fancy
    gitAndTools.git-trim
    git-review
    gh
    gist
    glab
    fossil
    binutils
    jq
    ocl-icd
    meld
    pythonPackages.markdown
    nixfmt
    global
    universal-ctags

    # web, chat & docs
    okular
    libreoffice
    gimp
    freecad
    firefox
    chromium
    thunderbird
    birdtray
    tor-browser-bundle-bin
    unstable.mattermost-desktop
    unstable.tdesktop
    slack
    linphone
    simple-scan

    (pkgs.writeScriptBin "wegwerf_firefox_clone"
      (builtins.readFile ../scripts/wegwerf_firefox_clone.sh))

    # desktop
    arandr
    feh
    scrot
    pavucontrol
    pasystray
    blueman
    arc-theme
    lxappearance
    myxclip
    stripescapecodes
    lxqt.lxqt-policykit
    qt5ct
    v4l-utils

    # misc
    fuse
    sshfs-fuse
    cifs-utils
    google-drive-ocamlfuse
    nextcloud-client
    enpass
    chezmoi
    zip unzip
    p7zip
  ];

  services.lorri.enable = true;
  services.emacs = {
    enable = true;
    install = true;
  };
  services.openssh.forwardX11 = true;
  documentation.man.enable = true;

  sound = {
    enable = true;
    mediaKeys.enable = true;
    mediaKeys.volumeStep = "5";
  };
  hardware.pulseaudio.enable = lib.mkForce false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # copied from https://github.com/NixOS/nixpkgs/issues/102547 for high quality cals
  services.pipewire.media-session.config.bluez-monitor.rules = [
    {
      # Matches all cards
      matches = [ { "device.name" = "~bluez_card.*"; } ];
      actions = {
        "update-props" = {
          "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
          # mSBC is not expected to work on all headset + adapter combinations.
          "bluez5.msbc-support" = true;
        };
      };
    }
    {
      matches = [
        # Matches all sources
        { "node.name" = "~bluez_input.*"; }
        # Matches all outputs
        { "node.name" = "~bluez_output.*"; }
      ];
      actions = {
        "node.pause-on-idle" = false;
      };
    }
  ];

  systemd.services.audio-off = {
    description = "Mute audio before suspend";
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      Environment = "XDG_RUNTIME_DIR=/run/user/1000";
      User = "seb";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
    };
  };

  # wireshark capturing
  users.groups.wireshark.members = [ "seb" ];
  programs.wireshark.enable = true;

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

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.kernelParams = [ "security=apparmor" ];
  boot.supportedFilesystems = [ "cifs" ];
  boot.kernel.sysctl = { "vm.swappiness" = 10; };

  services.xserver = {
    enable = true;
    layout = "us(altgr-intl)";
    xkbOptions = "ctrl:nocaps,compose:caps,terminate:ctrl_alt_bksp";
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };

  services.dbus = {
    packages = [ pkgs.gnome.gnome-keyring pkgs.gcr ];
  };
  services.gvfs.enable = true;

  services.gnome = {
    sushi.enable = true;
    gnome-keyring.enable = true;
  };

  services.redshift = {
    enable = true;
    brightness.day = "1";
    brightness.night = "0.6";
    temperature.day = 5500;
    temperature.night = 3400;

    extraOptions = [ "-v" ];
  };
  location = {
    provider = "manual";
    latitude = 54.515;
    longitude = 9.569;
  };

  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;

    fonts = with pkgs; [
      carlito
      comic-relief
      corefonts
      fantasque-sans-mono
      font-awesome
      gohufont
      google-fonts
      ipafont
      (nerdfonts.override { fonts = [
        "AnonymousPro"
        "DroidSansMono"
        "FiraCode"
        "HeavyData"
        "Inconsolata"
        "Iosevka"
        "Noto"
        "SourceCodePro"
        "Terminus"
        "Ubuntu"
      ]; })
      victor-mono
    ];

    fontconfig = {
      enable = lib.mkDefault true;
      antialias = true;
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
      hinting = {
        enable = true;
        autohint = false;
      };
      useEmbeddedBitmaps = true;
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font Mono" "IPAGothic" ];
        sansSerif = [ "Roboto" "IPAGothic" ];
        serif = [ "Roboto Slab" "IPAPMincho" ];
      };
    };
  };

  console.font = "latarcyrheb-sun32";

  services.printing = {
    enable = true;
    startWhenNeeded = true;
    drivers = with pkgs; [ gutenprint hplip ];
  };
  hardware.printers = {
    ensurePrinters = [{
      name = "LaserJet_Sandweg";
      ppdOptions = {
        PageSize = "A4";
        Duplex = "DuplexNoTumble";
      };
      # lpinfo -v  or   hp-setup -i  or   hp-makeuri <IP>
      deviceUri = "hp:/net/HP_LaserJet_Pro_M148-M149?ip=192.168.190.76";
      # lpinfo -m
      model = "HP/hp-laserjet_pro_m148-m149-ps.ppd.gz";
      description = "LaserJet Sandweg";
      location = "Sandweg";
    }];
    ensureDefaultPrinter = "LaserJet_Sandweg";
  };
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };

  services.colord = { enable = true; };

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  boot.kernelModules = [ "vboxdrv" ];
  virtualisation = {
    virtualbox.host = {
      #enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.linuxPackages_latest.virtualbox;
    };
    #lxd.enable = lib.mkDefault true;
    docker = {
      enable = lib.mkDefault true;
      extraOptions = lib.mkDefault "--experimental";
      autoPrune = {
        enable = true;
        dates = "daily";
      };
    };
    libvirtd.enable = true;
    #waydroid.enable = true;
  };
  users.groups.vboxusers.members = [ "seb" ];
  users.groups.libvirtd.members = [ "seb" ];

  # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  networking.firewall = {
    allowedTCPPorts = [
      22
      8010 # chromecast with VLC
    ];
  };

  services.udev.extraRules = ''
    # Thunderbolt
    # Always authorize thunderbolt connections when they are plugged in.
    # This is to make sure the USB hub of Thunderbolt is working.
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"

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
      ExecStart = ''
        ${pkgs.xautolock}/bin/xautolock -time 15 -locker "i3lock -c b31051 -t"'';
    };
  };

  programs = {
    nm-applet.enable = true;
    dconf.enable = true;
    ssh.startAgent = true;
    gnupg.agent.enable = true;
    gnupg.agent.pinentryFlavor = "gnome3";
    zsh = {
      shellAliases = {
        wergwerf_firefox = "firefox --new-instance --profile $(mktemp -d)";
        wergwerf_chromium = "chromium --user-data-dir $(mktemp -d)";
        youtube_dl =
          "${pkgs.youtube-dl}/bin/youtube-dl -o '%(title)s.%(ext)s' --no-call-home -f 'bestaudio'";
        youtube_playlist_dl =
          "youtube_dl -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' --download-archive downloaded.txt --no-overwrites -ic --yes-playlist --socket-timeout 5";
        youtube_mp3 =
          "youtube_dl --extract-audio --audio-format mp3 --audio-quality 0";
        youtube_playlist_mp3 =
          "youtube_playlist_dl --extract-audio --audio-format mp3 --audio-quality 0 --socket-timeout 5";
        flac2mp3 =
          "${pkgs.parallel}/bin/parallel ${pkgs.ffmpeg}/bin/ffmpeg -i {} -qscale:a 0 {.}.mp3 ::: ./*.flac";
      };
      interactiveShellInit = ''
        eval "$(direnv hook zsh)"
      '';
    };
  };
  services.earlyoom.enable = lib.mkDefault true;

  qt5 = {
    enable = true;
    platformTheme = "gtk2";
    style = "cleanlooks";
  };

  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QTA_PLATFORMTHEME = "qt5ct";
    GTK_USE_PORTAL = "0";
  };
}
