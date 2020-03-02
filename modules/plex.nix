{ pkgs, lib, config, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };

  plex-plugin-mediaccc = pkgs.fetchFromGitHub {
    owner = "cccc";
    repo = "MediaCCC.bundle";
    rev = "6922c868dcef6e3125c8297af56b8b401cb11485";
    sha256 = "0fsp1qlj02l3p1kfcxa0k3m4jmpj6ijbna6aad2bnpskfr1r13xy";
  };
  plex-plugin-youtube = pkgs.fetchFromGitHub {
    owner = "kolsys";
    repo = "YouTubeTV.bundle";
    rev = "f4ac7121c6525dc5b7599509dd5033479a52842b";
    sha256 = "1c59rmkfda9bs64cj11kbwpzi8gvykspddvqby9im5hz3vki8xnx";
  };
  plex-plugin-mediathek = pkgs.fetchFromGitHub {
    owner = "rols1";
    repo = "Plex-Plugin-ARDMediathek2016";
    rev = "01c000b14bfc794913fc6bdba09a84ffd319438a";
    sha256 = "1vddlp1pbb56j7asb5qky9fcm6fjk8kkxmpv5g9v0xrx4zq2m8q2";
  };
in
{
  imports = [
    ./server.nix
  ];

  environment.systemPackages = with pkgs; [
    libva
  ];

  services.plex = {
    enable = true;
    openFirewall = true;
    package = pkgs.unstable.plex;
    extraPlugins = [
      plex-plugin-mediaccc
      plex-plugin-mediathek
      plex-plugin-youtube
    ];
  };

  users.users."plex".extraGroups = [
    "video"
    "render"
  ];

  services.nginx.virtualHosts."plex.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:32400";
      proxyWebsockets = true;

      extraConfig = ''
        proxy_buffering off;
        proxy_redirect off;
        proxy_cookie_path /web/ /;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
      '';
    };

    extraConfig = ''
      access_log off;

      client_max_body_size 100M;
      send_timeout 100m;

      gzip on;
      gzip_vary on;
      gzip_min_length 1000;
      gzip_proxied any;
      gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
    '';
  };


	#add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

	# #Forward real ip and host to Plex
	# proxy_set_header Host $host;
	# proxy_set_header X-Real-IP $remote_addr;
	# proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	# proxy_set_header X-Forwarded-Proto $scheme;
        # # Plex headers
        # proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
        # proxy_set_header X-Plex-Device $http_x_plex_device;
        # proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
        # proxy_set_header X-Plex-Platform $http_x_plex_platform;
        # proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
        # proxy_set_header X-Plex-Product $http_x_plex_product;
        # proxy_set_header X-Plex-Token $http_x_plex_token;
        # proxy_set_header X-Plex-Version $http_x_plex_version;
        # proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
        # proxy_set_header X-Plex-Provides $http_x_plex_provides;
        # proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
        # proxy_set_header X-Plex-Model $http_x_plex_model;

        #     proxy_set_header        Host                      $server_addr;
        #     proxy_set_header        Referer                   $server_addr;
        #     proxy_set_header        Origin                    $server_addr;

}
