{ pkgs, lib, config, ... }:
let
  dhparam-file-for-nixos = pkgs.stdenv.mkDerivation rec {
    name = "dhparam-file-for-nginx";

    nativeBuildInputs = with pkgs; [ openssl ];
    phases = [ "installPhase" ];
    installPhase = ''
      openssl dhparam -out $out/dhparam.pem 4096
    '';
  };
  dhparam-file = import dhparam-file-for-nixos;
  cfg = config;
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/hardened.nix>
    <nixpkgs/nixos/modules/profiles/headless.nix>
    <nixpkgs/nixos/modules/profiles/minimal.nix>

    ./base.nix
  ];

  security.allowUserNamespaces = lib.mkForce true;
  # security.lockKernelModules = lib.mkForce true;

  services.fail2ban = {
    enable = true;
    jails.ssh-iptables = ''
      enabled = true
    '';
  };

  networking.firewall = {
    #allowedTCPPorts = [ 9100 ];
    allowPing = true;
  };

  services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        # "netclass" "exec" "edec" "boottime"
        "arp" "bonding" "conntrack" "cpu" "diskstats"
        "entropy" # "exec"
        "filefd" "filesystem" "hwmon"
        "loadavg" "mdadm" "meminfo"
        "netdev" "netstat"
        "sockstat" "systemd" "textfile" "time" "vmstat" "wifi" "zfs"
      ];
      extraFlags = [
        "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
        ""
      ];
    };

    system.activationScripts.node-exporter-system-version = ''
      mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
      (
        cd /var/lib/prometheus-node-exporter-text-files
        (
          echo -n "system_version ";
          readlink /nix/var/nix/profiles/system | cut -d- -f2
        ) > system-version.prom.next
        mv system-version.prom.next system-version.prom
      )
    '';

  services.mysql = {
    bind = lib.mkDefault "::1";
    package = lib.mkDefault pkgs.mysql57;
  };
  services.mysqlBackup = {
    enable = (if cfg.services.mysql.enable then true else false);
  };

  services.nginx = {
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;

    # https://cipherli.st/
    sslProtocols = "TLSv1.3";
    #sslDhparam = dhparam-file;
    sslCiphers = "EECDH+AESGCM:EDH+AESGCM";

    proxyResolveWhileRunning = true;
    resolver.addresses = lib.mkDefault [
      "8.8.8.8"
      "9.9.9.9"
      "1.1.1.1"
    ];
    resolver.valid = lib.mkDefault "300s";

    commonHttpConfig = ''
      ssl_session_tickets off;

      add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
      add_header X-Frame-Options DENY;
      add_header X-Content-Type-Options nosniff;
      add_header X-XSS-Protection "1; mode=block";
    '';
    eventsConfig = ''
      use epoll;
    '';
    appendHttpConfig = ''
      # directio for larger files
      # sendfile for smaller ones
      #directio 16M;
      #output_buffers 2 1M;
      #sendfile on;
      #sendfile_max_chunk 512k;

      # send headers in one piece instead of one by one
      #tcp_nopush on;
    '';
    appendConfig = lib.mkBefore ''
      worker_processes auto;
      worker_rlimit_nofile 10000; # Max # of open FDs
    '';

    virtualHosts."default" = {
      enableACME = false;
      serverName = null;
      default = true;
      globalRedirect = "duckduckgo.com";
    };
  };
  services.prometheus.exporters.nginx = {
    enable = (if cfg.services.nginx.enable then true else false);
  };
}
