{ config, pkgs, lib, ... }:
let
  hostName = "nextcloud.sandkasten.ds.ag";
in {
  imports = [
    ./server.nix
  ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud19;
    hostName = hostName;
    https = true;

    maxUploadSize = "2048M";
    nginx.enable = true;

    # nextcloud-occ config:system:set redis 'host' --value 'localhost' --type string
    # nextcloud-occ config:system:set redis 'port' --value 6379 --type integer
    # nextcloud-occ config:system:set memcache.local --value '\OC\Memcache\Redis' --type string
    # nextcloud-occ config:system:set memcache.locking --value '\OC\Memcache\Redis' --type string
    caching.redis = true;

    config = {
      adminuser = "admin";
      adminpassFile = "/etc/nixos/secrets/nextcloud-adminpass";
      dbpassFile = "/etc/nixos/secrets/nextcloud-dbpass";
    };

    autoUpdateApps.enable = true;
  };

  services.redis = {
    enable = true;
  };

  services.nginx.virtualHosts."nextcloud.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    extraConfig = ''
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    '';

    # https://github.com/NixOS/nixpkgs/issues/73585
    locations."^~ /.well-known/acme-challenge/" = {
      extraConfig = ''
        allow all;
        root /var/lib/acme/acme-challenge;
        auth_basic off;
      '';
    };
  };
}
