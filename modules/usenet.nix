{ pkgs, lib, config, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
in
{
  imports = [
    ./server.nix
    #<unstable/nixos/modules/services/misc/radarr.nix>
    #<unstable/nixos/modules/services/misc/sonarr.nix>
  ];

  #disabledModules = [
  #  "services/misc/radarr.nix"
  #  "services/misc/sonarr.nix"
  #];

  nixpkgs.config.packageOverrides = super: let self = super.pkgs; in {
    radarr = unstable.radarr;
    sonarr = unstable.sonarr;
  };

  services.nzbget = {
    enable = true;
  };

  services.nginx.virtualHosts."nzbget.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:6789";

      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };

    extraConfig = ''
      access_log off;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    '';
  };

  services.radarr = {
    enable = true;
    group = "filme";
  };

  services.nginx.virtualHosts."radarr.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:7878";

      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };

    extraConfig = ''
      access_log off;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    '';
  };

  services.lidarr = {
    enable = true;
    group = "musik";
    package = unstable.lidarr;
  };

  services.nginx.virtualHosts."lidarr.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:8686";

      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };

    extraConfig = ''
      access_log off;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    '';
  };

  services.sonarr = {
    enable = true;
    group = "serien";
  };

  services.nginx.virtualHosts."sonarr.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:8989";

      extraConfig = ''
        proxy_buffering off;
        proxy_redirect off;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

    extraConfig = ''
      access_log off;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    '';
  };

  services.jackett = {
    enable = true;
    package = unstable.jackett;
  };

  services.nginx.virtualHosts."jackett.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:9117";

      extraConfig = ''
        proxy_buffering off;
        proxy_redirect off;

        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   X-Forwarded-Host $http_host;
      '';
    };

    extraConfig = ''
      access_log off;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    '';
  };
}
