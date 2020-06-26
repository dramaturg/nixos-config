{ pkgs, lib, config, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball { config = removeAttrs config.nixpkgs.config [ "packageOverrides" ]; };
in
{
  imports = [
    ./server.nix
  ];

  environment.systemPackages = with pkgs; [
    libva-utils
    libva
  ];

  services.plex = {
    enable = true;
    #openFirewall = true;
    package = unstable.plex;
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
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

      client_max_body_size 100M;
      send_timeout 100m;

      gzip on;
      gzip_vary on;
      gzip_min_length 1000;
      gzip_proxied any;
      gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 32400 ];

    extraCommands = lib.mkMerge [ (lib.mkAfter ''
      #iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p tcp --dport 32400 -j nixos-fw-accept
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p tcp --dport 3005 -j nixos-fw-accept
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p tcp --dport 8324 -j nixos-fw-accept
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p tcp --dport 32469 -j nixos-fw-accept

      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p udp --dport 1900 -j nixos-fw-accept
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p udp --dport 5353 -j nixos-fw-accept
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p udp --dport 32410 -j nixos-fw-accept
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p udp --dport 32412 -j nixos-fw-accept
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p udp --dport 32413 -j nixos-fw-accept
      iptables -w -t filter -A nixos-fw -s 192.168.190.0/24 -p udp --dport 32414 -j nixos-fw-accept
    '') ];
  };
}
