{ pkgs, lib, config, options, modulesPath, stdenv, fetchurl }:
let
  py-plexapi = pkgs.pythonPackages.buildPythonApplication rec {
    pname = "PlexAPI";
    version = "3.1.0";

    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "0kffx74ppvadkg3lv7dd03h3fmas1j8l2kkhgxrr6ssb6mpqfi20";
    };

    doCheck = false;
    buildInputs = with pkgs.pythonPackages; [
      requests
      websocket_client
      tqdm
    ];

    meta = with stdenv.lib; {
      license = licenses.bsd;
    };
  };
  py-sonic = pkgs.pythonPackages.buildPythonApplication rec {
    pname = "py-sonic";
    version = "0.6.2";

    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "1pwbpvf3qm32m1d26m8c3m3qnlahsxkdpk90lf24f9f0prlldn58";
    };

    doCheck = false;

    meta = with stdenv.lib; {
      license = licenses.gpl3;
    };
  };
  mopidy-plex = pkgs.pythonPackages.buildPythonApplication rec {
    pname = "Mopidy-Plex";
    version = "0.1.0b";

    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "15xmib4ynh33afjyqdmqxvj3blc68d97n5vp7xk8zx3yw6jk88zd";
    };

    propagatedBuildInputs = with pkgs; [ mopidy py-plexapi ];

    doCheck = false;

    meta = with stdenv.lib; {
      homepage = https://www.mopidy.com/;
      description = "Mopidy extension for playing music from Plex";
      license = licenses.apl2;
    };
  };
  mopidy-subsonic = pkgs.pythonPackages.buildPythonApplication rec {
    pname = "Mopidy-Subsonic";
    version = "1.0.0";

    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "0wmf0a7aynvn32pf8p02d53a8vg3l33yvwfwdy4gcx93pm3psgp2";
    };

    propagatedBuildInputs = with pkgs; [ mopidy py-sonic ];

    doCheck = false;

    meta = with stdenv.lib; {
      homepage = https://www.mopidy.com/;
      description = "Mopidy extension for playing music from Subsonic";
      license = licenses.mit;
    };
  };
in
{
  imports =
  [
    #./server.nix
  ];

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
      mopidy-iris
      mopidy-musicbox-webclient
      mopidy-plex
      mopidy-youtube
    ];
    configuration = ''
      [core]
      max_tracklist_length = 10000
      restore_state = false

      [mpd]
      enabled = true
      hostname = ::
      port = 6600
      password = xxx
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

      [local]
      enabled = true
      media_dir = /shtick
    '';
  };

  networking.firewall.allowedTCPPorts = [
    6600 # mopidy mpd
  ];

  environment.systemPackages = with pkgs; [
    mpc_cli
    ncmpcpp
  ];
}
