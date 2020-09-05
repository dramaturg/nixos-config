{ pkgs, lib, config, ... }:
let
  dhparam-file-for-nixos = pkgs.stdenv.mkDerivation rec {
    name = "dhparam-file-for-nginx";

    buildInputs = with pkgs; [ openssl ];
    phases = [ "installPhase" ];
    installPhase = let
        machineId = lib.readFile /etc/machine-id;
      in ''
        touch $out/$machineId
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
  security.lockKernelModules = lib.mkForce true;
  boot.kernelModules = [
    "veth" # for containers
  ];
  boot.cleanTmpDir = true;
  environment.noXlibs = lib.mkDefault true;

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
    package = lib.mkDefault pkgs.mysql80;
  };
  services.mysqlBackup = {
    enable = (if cfg.services.mysql.enable then true else false);
  };

  security.acme = {
    email = "seb@ds.ag";
    acceptTerms = true;
  };

  services.nginx = {
    recommendedGzipSettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;

    # https://ssl-config.mozilla.org/#server=nginx&config=intermediate
    # some android things shit their pants with TLS1.3 ....
    sslProtocols = lib.mkDefault "TLSv1.2 TLSv1.3";
    #sslDhparam = dhparam-file;
    sslCiphers = lib.mkDefault "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

    resolver.addresses = lib.mkDefault [ "127.0.0.53" ];
    resolver.valid = lib.mkDefault "300s";
    proxyResolveWhileRunning = true;

    eventsConfig = ''
      use epoll;
    '';
    appendHttpConfig = ''
      # directio for larger files
      # sendfile for smaller ones
      directio 16M;
      output_buffers 2 1M;
      sendfile_max_chunk 512k;
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
    virtualHosts."localhost" = {
      enableACME = false;
      serverName = "localhost";
      listen = [ {"addr" = "127.0.0.1"; "port" = 80;} ];

      locations."/nginx_status" = {
        extraConfig = ''
          # Enable Nginx stats
          stub_status on;
        '';
      };
    };
  };
  services.prometheus.exporters.nginx = {
    enable = (if cfg.services.nginx.enable then true else false);
    scrapeUri = "http://127.0.0.1/nginx_status";
  };
  systemd.services.prometheus-nginx-exporter.requires = ["nginx.service"];
  services.prometheus.scrapeConfigs = [{
    job_name = "nginx";
    scrape_interval = "60s";
    static_configs = [{ targets = [ "localhost:9113" ]; }];
  }];
}
