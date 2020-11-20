{ pkgs, lib, config, ... }:

{
  networking.nat = {
    enable = lib.mkDefault true;
    internalInterfaces = ["ve-torrent"];
  };

  containers.torrent = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    enableTun = true;
    hostAddress = "192.168.17.10";
    localAddress = "192.168.17.11";

    bindMounts = {
      "/var/lib/transmission" = {
        hostPath = "/var/lib/transmission";
        isReadOnly = false;
      };
      "/torrents" = {
        hostPath = "/iced/misc/torrents";
        isReadOnly = false;
      };
      "/iced/filme/.inc" = {
        hostPath = "/iced/filme/.inc";
        isReadOnly = false;
      };
      "/iced/serien/.inc" = {
        hostPath = "/iced/serien/.inc";
        isReadOnly = false;
      };
      "/iced/musik/.inc" = {
        hostPath = "/iced/musik/.inc";
        isReadOnly = false;
      };
    };

    config = {config, pkgs, ... }: {
      imports = [ 
        ./pia-system.nix
      ];

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 9091 51415];
        allowedUDPPorts = [ 51415];
      };

      #networking.nameservers = [ "9.9.9.9" "8.8.8.8" ];
      environment.etc = {
	 "resolv.conf".text = "nameserver 9.9.9.9\nnameserver 8.8.8.8\n";
      };

      users.users.transmission.uid = lib.mkForce 1000;

      services = {
        openvpn.servers."netherlands".autoStart = true;
        transmission = {
          enable = true;
          settings = {
             alt-speed-down = 500;
             alt-speed-time-begin = 540;
             alt-speed-time-day = 127;
             alt-speed-time-enabled = true;
             alt-speed-time-end = 1020;
             alt-speed-up = 150;

             download-dir = "/torrents";
             incomplete-dir = "/torrents/.incomplete";
             incomplete-dir-enabled = true;

             umask = 2; # 0o002 in decimal as expected by Transmission
             utp-enabled = true;

	     rpc-bind-address = "0.0.0.0";
	     rpc-port = 9091;
             rpc-host-whitelist = "127.0.0.1,192.168.*.*,transmission.sandkasten.ds.ag";
             rpc-host-whitelist-enabled = true;
             rpc-whitelist = "127.0.0.1,192.168.*.*";
             rpc-whitelist-enabled = true;
	     rpc-authentication-required = true;
	     rpc-username = "seb";
	     rpc-password = builtins.readFile ../secrets/transmission;

	     peer-port = 51415;

             blocklist-enabled = true;
             # https://www.iblocklist.com/lists.php
             blocklist-url = "http://list.iblocklist.com/?list=ydxerpxkpcfqjaybcssw&fileformat=p2p&archiveformat=gz";

             script-torrent-done-enabled = false;
             script-torrent-done-filename = "";
          };
        };
      };

      users.groups = {
        musik = {
          gid = 997;
          members = [ "transmission" ];
        };
        filme = {
          gid = 999;
          members = [ "transmission" ];
        };
        serien = {
          gid = 995;
          members = [ "transmission" ];
        };
      };
    };
  };

  services.nginx.virtualHosts."transmission.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://192.168.17.11:9091";

      extraConfig = ''
        proxy_buffering off;
        proxy_redirect off;

        proxy_pass_header X-Transmission-Session-Id;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

	proxy_headers_hash_max_size 512;
	proxy_headers_hash_bucket_size 128; 
      '';
    };
    extraConfig = ''
      access_log off;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    '';
  };
}
