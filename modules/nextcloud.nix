{ config, pkgs, lib, ... }:
{
  imports = [
    ./server.nix
  ];

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.sandkasten.ds.ag";
    https = true;

    maxUploadSize = "2048M";
    nginx.enable = true;

    config = {
      adminuser = "admin";
      adminpassFile = "/etc/nixos/secrets/nextcloud-adminpass";
      dbpassFile = "/etc/nixos/secrets/nextcloud-dbpass";
      #overwriteProtocol = "https";
    };
    autoUpdateApps.enable = true;
  };

  services.nginx.virtualHosts."nextcloud.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

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
