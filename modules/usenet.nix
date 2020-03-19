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
    #<unstable/nixos/modules/services/misc/headphones.nix>
  ];

  #disabledModules = [
  #  "services/misc/radarr.nix"
  #  "services/misc/sonarr.nix"
  #  "services/misc/headphones.nix"
  #];

  nixpkgs.config.packageOverrides = super: let self = super.pkgs; in {
    radarr = unstable.radarr;
    sonarr = unstable.sonarr;
    headphones = unstable.headphones;
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
    '';
  };

  services.headphones = {
    enable = true;
    group = "musik";
    host = "127.0.0.1";
  };

  services.nginx.virtualHosts."headphones.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:8181";

      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };

    extraConfig = ''
      access_log off;
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
    '';
  };
}
