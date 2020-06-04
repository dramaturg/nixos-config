
{ config, lib, pkgs, fetchPypi, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball { config = removeAttrs config.nixpkgs.config [ "packageOverrides" ]; };

  xbee = pkgs.python37.pkgs.buildPythonPackage rec {
    pname = "XBee";
    version = "2.3.2";

    buildInputs = [
      (pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
        pyserial
        tornado
      ]))
    ];

    src = pkgs.python37Packages.fetchPypi {
      inherit pname version;
      sha256 = "0mxn9phypb5pzxk160ynl19gzywryh2mnc52diz9lh036kk6vh3p";
    };
  };  

  xbee-helper = pkgs.python37.pkgs.buildPythonPackage rec {
    pname = "xbee-helper";
    version = "0.0.7";

    doCheck = false;
    #checkInputs = [
    #  (python37.withPackages (pythonPackages: with pythonPackages; [
    #    pytest
    #    pytest-runner
    #  ]))];
    buildInputs = [
      (pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
        pyserial
      ]))
      xbee
    ];

    src = pkgs.python37Packages.fetchPypi {
      inherit pname version;
      sha256 = "0rzg06x27shcmgsbq2jchrmy2a303jghhpywnymk8gfcjm9hcyq6";
    };
  };  

  click-datetime = pkgs.python37.pkgs.buildPythonPackage rec {
    pname = "click-datetime";
    version = "0.2";

    buildInputs = [
      (pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
        click
      ]))
    ];

    configurePhase = ''
      touch README.md
    '';

    src = pkgs.python37Packages.fetchPypi {
      inherit pname version;
      sha256 = "05g1lpyrbbmcb5i2jrpy123afcvrm2s434d4ank885vincjasqn5";
    };
  };  

  pyHS100 = pkgs.python37.pkgs.buildPythonPackage rec {
    pname = "pyHS100";
    version = "0.3.5";

    buildInputs = [
      click-datetime
      (pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
        click
        typing
      ]))
    ];

    src = pkgs.python37Packages.fetchPypi {
      inherit pname version;
      sha256 = "0nrq1333q765zsb0h8zp6kl32c3pybcpq558ky4pwph0b3rl4alx";
    };
  };  
in
{
  imports = [
    ./server.nix
  ];

  boot.kernelModules = [
    "ftdi_sio"
  ];

  #nixpkgs.config.packageOverrides = pkgs: with pkgs; rec {

  environment.systemPackages = with pkgs; [
    home-assistant-cli
  ];

  users.groups.dialout.members = [ "hass" ];

  services.udev.extraRules = ''
    # z-wave USB stick
    # Bus 001 Device 024: ID 0658:0200 Sigma Designs, Inc. Aeotec Z-Stick Gen5 (ZW090) - UZB
    SUBSYSTEM=="tty", ATTR{idVendor}=="0658", ATTR{idProduct}=="0200", \
        MODE="0660", OWNER="hass", GROUP="dialout", SYMLINK+="zwave"
    # Bus 001 Device 025: ID 0451:16ae Texas Instruments, Inc. CC2531 USB Dongle
    SUBSYSTEM=="tty", ATTR{idVendor}=="0451", ATTR{idProduct}=="16ae", \
        MODE="0660", OWNER="hass", GROUP="dialout", SYMLINK+="zigbee"
  '';

  services.home-assistant = {
    enable = true;
    port = 8123;

    package = pkgs.home-assistant.override {
      extraPackages = ps: with ps; [
        hbmqtt
        homeassistant-pyozw
        unstable.openzwave
        #pyHS100
        pyserial
        speedtest-cli
	#xbee-helper
      ];
    };

    config = {
      homeassistant = { name = "Sandweg"; };
      http = { base_url = "http://192.168.190.57:8123"; };
      config = {};
      frontend = {};
      #mobile_app = {};
      #default_config = "";

      zwave = {
        #usb_path = "/dev/zwave";
        usb_path = "/dev/ttyACM0";
        polling_interval = 300000; # 5 minutes
        #autoheal = true;
	#debug = true;
      };

      zigbee = {
        device = "/dev/ttyACM1";
      };

      #tplink = { };

      climate = [
        { platform = "zwave"; }
      ];

      sensor = [
        #{ platform = "deutsche_bahn"; from = "Schleswig"; to = "Hamburg"; };
        #{ platform = "deutsche_bahn"; from = "Schleswig"; to = "Flensburg"; };
        { platform = "zigbee"; type = "temperature";
          name = "Temperatur Werkstatt";
          address = "2016DP0535";
        }
      ];

      binary_sensor = [
        { platform = "workday"; country = "CH"; province = "ZH"; }
      ];

      weather = [
        { platform = "openweathermap";
          api_key = "c13fdcb3a89b6a9a7da5b3c9811bdf20"; }
      ];

      device_tracker = [
        #{ platform = "fritz"; }
      ];

      zeroconf = {};
      sun = {};
      #groups = {};
      history = {};
      logbook = {};

      speedtestdotnet = {
        scan_interval = { minutes = 30; };
        monitored_conditions = [
          "ping"
          "download"
          "upload"
        ];
      };

      automations = [
        {
          trigger = { platform = "time"; at = "08:00:00"; };
          action = [
            {
              service = "climate.set_temperature";
              data = {
                entity_id = "climate.Buero";
                temperature = 20;
                hvac_mode = "heat";
              };
            }
          ];
        }
        {
          trigger = { platform = "time"; at = "18:00:00"; };
          action = [
            {
              service = "climate.set_temperature";
              data = {
                entity_id = "climate.Buero";
                temperature = 16;
                hvac_mode = "heat";
              };
            }
          ];
        }
      ];
    };
    configWritable = true;
    lovelaceConfigWritable = true;
  };

  networking.firewall = {
    extraCommands = lib.mkMerge [ (lib.mkAfter ''
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p tcp --dport 8123 -j nixos-fw-accept
    '') ];
  };
}

