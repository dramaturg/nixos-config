{ pkgs, lib, config, ... }:
# https://www.foxypossibilities.com/2018/02/04/running-matrix-synapse-on-nixos/
# https://kaushikc.org
let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball { config = removeAttrs config.nixpkgs.config [ "packageOverrides" ]; };
  cfg = config;
in
{
  imports = [
    ./server.nix
  ];

  options = {
    mymatrix = {
      servername = lib.mkOption {
        type = lib.types.str;
      };
      enable_registration = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      jitsi = lib.mkOption {
        type = lib.types.str;
        default = "meet.jit.si";
      };
      identity_server = lib.mkOption {
        type = lib.types.str;
        default = "vector.im";
      };
    };
  };

  config = {
    nixpkgs.overlays = [
      (self: super: {
          element-web = unstable.element-web.override {
              conf = {
                   default_server_config = {
                      "m.homeserver" = {
                        "base_url" = "https://${cfg.mymatrix.servername}";
                        "server_name" = "${cfg.mymatrix.servername}";
                      };
                      "m.identity_server" = {
                        "base_url" = "https://${cfg.mymatrix.identity_server}";
                      };
                   };
                   "disable_custom_urls" = true;
                   "default_theme" = "dark";
                   jitsi.preferredDomain = "${cfg.mymatrix.jitsi}";
              };
          };
      })
    ];

    services.matrix-synapse = {
      enable = true;
      server_name = cfg.mymatrix.servername;
      public_baseurl = "https://${cfg.mymatrix.servername}/";

      database_type = "sqlite3";
      url_preview_enabled = true;
      enable_registration = cfg.mymatrix.enable_registration;

      turn_uris = [
        "turn:turn.matrix.org:3478?transport=udp"
        "turn:turn.matrix.org:3478?transport=tcp"
      ];

      tls_certificate_path = "/var/lib/acme/${cfg.mymatrix.servername}/fullchain.pem";
      tls_private_key_path = "/var/lib/acme/${cfg.mymatrix.servername}/key.pem";

      listeners = [
        { # federation
          bind_address = "";
          port = 8448;
          resources = [
            { compress = true; names = [ "client" "webclient" ]; }
            { compress = false; names = [ "federation" ]; }
          ];
          tls = true;
          type = "http";
          x_forwarded = false;
        }
        { # client
          bind_address = "127.0.0.1";
          port = 8008;
          resources = [
            { compress = true; names = [ "client" "webclient" "metrics" ]; }
          ];
          tls = false;
          type = "http";
          x_forwarded = true;
        }
      ];

      extraConfig = ''
        max_upload_size: "50M"

        matrix_mxisd_enabled: false
        matrix_mailer_enabled: false

        enable_metrics: true
      '';
    };

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.mymatrix.servername}" = {
        forceSSL = true;
        enableACME = true;

        basicAuth = { prometheus = "notsecure"; };

        locations."/" = {
          root = pkgs.element-web;

          extraConfig = ''
            index index.html;
            auth_basic off;
          '';
        };

        locations."/.well-known/matrix/server" = {
          extraConfig = ''
            return 200 '{"m.server": "${cfg.mymatrix.servername}:8448"}';
            add_header Content-Type application/json;
            auth_basic off;
          '';
        };

        locations."/.well-known/matrix/client" = {
          extraConfig = ''
            return 200 '{"m.homeserver": {"base_url": "https://${cfg.mymatrix.servername}"},"m.identity_server": {"base_url": "https://${cfg.mymatrix.identity_server}"}}';
            add_header Content-Type application/json;
            add_header "Access-Control-Allow-Origin" *;
            auth_basic off;
          '';
        };

        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:8008";

          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
            auth_basic off;
          '';
        };

        locations."/_synapse/metrics" = {
          proxyPass = "http://127.0.0.1:8008";

          extraConfig = ''
            proxy_set_header X-Forwarded-For $remote_addr;
          '';
        };

        extraConfig = ''
          access_log off;
        '';
      };
    };


    security.acme.certs = {
      "${cfg.mymatrix.servername}" = {
        group = "matrix-synapse";
        postRun = "systemctl reload nginx.service; systemctl restart matrix-synapse.service";
      };
    };
    users.groups."matrix-synapse".members= [ "nginx" ];

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 8448 ];
    };
  };
}
