{ pkgs, lib, config, options, modulesPath, stdenv, fetchurl }:
let
  mopidy-subsonic = pkgs.pythonPackages.buildPythonApplication rec {
    pname = "Mopidy-Subsonic";
    version = "1.0.0";

    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "0wmf0a7aynvn32pf8p02d53a8vg3l33yvwfwdy4gcx93pm3psgp2";
    };

    propagatedBuildInputs = with pkgs; [ mopidy ];

    doCheck = false;

    meta = with stdenv.lib; {
      homepage = https://www.mopidy.com/;
      description = "Mopidy extension for playing music from Subsonic";
      license = licenses.mit;
    };
  };
  duckdnsToken = builtins.readFile ../secrets/duckdnstoken;
  updateduckdns = pkgs.writeScriptBin "updateduckdns" ''
    #!${pkgs.bash}/bin/bash

    echo url="https://www.duckdns.org/update?domains=campmpd&token='' + duckdnsToken + ''&ip=" \
      | curl -s -K -
  '';
in
{
  imports =
  [
    ./hardware/gpd_pocket.nix
    #./modules/embeddeddev.nix
    ./modules/laptop.nix
    #<nixpkgs/nixos/modules/profiles/hardened.nix>
  ];

  i3statusConfigFile = "i3status-gpd-pocket";

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/5 * * * *      root    ${updateduckdns}/bin/updateduckdns"
    ];
  };

  hardware.pulseaudio = {
    enable = true;
    systemWide = true;
    package = pkgs.pulseaudioFull;
    configFile = pkgs.writeText "default.pa" ''
      load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
    '';
  };

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-local-sqlite
      mopidy-mopify
      mopidy-subsonic
      mopidy-soundcloud
      mopidy-youtube
    ];
    configuration = ''
      [core]
      max_tracklist_length = 10000
      restore_state = false

      [mpd]
      enabled = true
      port = 6600
      password = 72b6ad896a871d0f04e6d2b4d420d7bb
      max_connections = 40
      connection_timeout = 60
      command_blacklist =
        listall
        listallinfo
      default_playlist_scheme = m3u

      [stream]
      enabled = true
      protocols =
        http
        https
        mms
        rtmp
        rtmps
        rtsp
      metadata_blacklist =
      timeout = 5000

      [audio]
      mixer = software
      mixer_volume =
      #output = autoaudiosink
      output = pulsesink server=127.0.0.1
      buffer_time =

      [softwaremixer]
      enabled = true

      #[local]
      #enabled = true
      #media_dir = /shtick

      [file]
      enabled = true
      media_dirs =
        /shtick|Shtick
      show_dotfiles = false
      follow_symlinks = false
      metadata_timeout = 1000

      [subsonic]
      hostname = sound.ds.ag
      port = 443
      username = camp
      password = 81b31f293d4ff53aaeddda128511381b
      ssl = yes
    '';
  };

  networking.firewall.allowedTCPPorts = [
    6600 # mopidy mpd
  ];

  environment.systemPackages = with pkgs; [
    mpc_cli
    ncmpcpp
  ];

  users = {
    extraUsers = {
      nerds = {
        home = "/home/nerds";
        description = "Nerd";
        isNormalUser = true;
        extraGroups = ["audio"];
        uid = 11000;
        openssh.authorizedKeys.keyFiles = [
          (builtins.fetchurl "https://darksystem.gitlab.io/ssh_pubkey_collection/authorized_keys.txt")
        ];
      };
    };
  };
}
