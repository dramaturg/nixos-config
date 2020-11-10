{ pkgs, lib, config, ... }:
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
    mymattermost = {
      sitename = lib.mkOption {
        type = lib.types.str;
      };
      servername = lib.mkOption {
        type = lib.types.str;
      };
      dbpassword = lib.mkOption {
        type = lib.types.str;
      };
      extraconfig = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };
    };
  };

  config = {
    services.mattermost = {
      enable = true;
      siteName = cfg.mymattermost.sitename;
      siteUrl = "https://${cfg.mymattermost.servername}";
      listenAddress = "[::1]:8065";
      localDatabasePassword = cfg.mymattermost.dbpassword;

      extraConfig = lib.foldl lib.recursiveUpdate
        {
          ServiceSettings = {
            EnableOAuthServiceProvider = true;
            EnablePostUsernameOverride = true;
            EnablePostIconOverride = true;
            EnableLinkPreviews = true;
            EnableMultifactorAuthentication = true;
            EnableUserAccessTokens = true;
            EnableCustomEmoji = true;
            EnableGifPicker = true;
            EnableUserTypingMessages = false;
            EnableTutorial = false;
            EnableEmailInvitations = false;
            EnableSVGs = true;
          };
          TeamSettings = {
            MaxUsersPerTeam = 500;
            RestrictDirectMessage = "team";
          };
          LogSettings = {
            EnableConsole = false;
          };
          FileSettings = {
            MaxFileSize = 157286400;
          };
          RateLimitSettings = {
            Enable = true;
            VaryByUser = true;
          };
          PrivacySettings = {
            ShowEmailAddress = false;
            ShowFullName = false;
          };
          ThemeSettings = {
            DefaultTheme = "Mattermost Dark";
          };
          ImageProxySettings = {
            Enable = true;
            ImageProxyType = "local";
          };
          GuestAccountsSettings = {
            Enable = false;
          };
        } [ cfg.mymattermost.extraconfig ];

      matterircd = {
        enable = true;
        parameters = [
          "-mmserver ${cfg.mymattermost.servername}"
          "-restrict ${cfg.mymattermost.servername}"
          "-mminsecure"
          "-bind [::1]:6667"
          "-tlsbind [::]:6697"
          "-tlsdir /var/lib/acme/${cfg.mymattermost.servername}/"
        ];
      };
    };
    systemd.services.matterircd = {
      requires = ["mattermost.service"];
      serviceConfig.Group = lib.mkForce "mattermost";
    };

    services.nginx = {
      enable = true;

      appendHttpConfig = ''
        proxy_headers_hash_max_size 512;
        proxy_headers_hash_bucket_size 128;
      '';

      virtualHosts."${cfg.mymattermost.servername}" = {
        forceSSL = true;
        enableACME = true;

        extraConfig = ''
        '';

        locations."~ /api/v[0-9]+/(users/)?websocket$" = {
          proxyPass = "http://[::1]:8065";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            client_max_body_size 50M;
            proxy_set_header X-Frame-Options SAMEORIGIN;
            proxy_buffers 256 16k;
            proxy_buffer_size 16k;
            client_body_timeout 60;
            send_timeout 300;
            lingering_timeout 5;
            proxy_connect_timeout 90;
            proxy_send_timeout 300;
            proxy_read_timeout 90s;
          '';
        };

        locations."/" = {
          proxyPass = "http://[::1]:8065";
          extraConfig = ''
            client_max_body_size 50M;
            proxy_set_header Connection "";
            proxy_set_header X-Frame-Options SAMEORIGIN;
            proxy_buffers 256 16k;
            proxy_buffer_size 16k;
            proxy_read_timeout 600s;
            proxy_http_version 1.1;
          '';
        };
      };
    };


    security.acme.certs = {
      "${cfg.mymattermost.servername}" = {
        group = "mattermost";
        postRun = "systemctl reload mattermost.service; systemctl reload matterircd.service";
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 6697 ];
    };
  };
}
