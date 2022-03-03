{ pkgs, lib, config, ... }:
let
  dhparam-file-for-nixos = pkgs.stdenv.mkDerivation rec {
    name = "dhparam-file-for-nginx";

    buildInputs = with pkgs; [ openssl ];
    phases = [ "installPhase" ];
    installPhase = let machineId = lib.readFile /etc/machine-id;
    in ''
      touch $out/$machineId
      openssl dhparam -out $out/dhparam.pem 4096
    '';
  };
  dhparam-file = import dhparam-file-for-nixos;
  node-exporter-textfile-collector-scripts = with pkgs;
    stdenv.mkDerivation rec {
      name = "node-exporter-textfile-collector-scripts";

      src = fetchFromGitHub {
        owner = "janw";
        repo = "node-exporter-textfile-collector-scripts";
        rev = "765a349524219b9e03912aa516a898f116a3dd90";
        sha256 = "1rwy8vpc1j2sz58hc1hm7s6dcn2gfdj3hqj7lnj3zp1m117kbay3";
      };

      installPhase = ''
        mkdir -p "$out/bin"
        install -m755 -D *.sh *.py *_[^\.]\+ $out/bin/
      '';

      patches = [
        "${pkgs.writeText "smartmon.patch" ''
          --- ./smartmon.sh.org 1970-01-01 01:00:01.000000000 +0100
          +++ ./smartmon.sh 2021-03-11 18:37:29.997702086 +0100
          @@ -230,9 +230,6 @@
             sat+megaraid*) smartctl -A -d "''${type}" "''${disk}" | parse_smartctl_attributes "''${disk_labels}" || true ;;
             scsi) smartctl -A -d "''${type}" "''${disk}" | parse_smartctl_scsi_attributes "''${disk_labels}" || true ;;
             megaraid*) smartctl -A -d "''${type}" "''${disk}" | parse_smartctl_scsi_attributes "''${disk_labels}" || true ;;
          -  *)
          -    echo "disk type is not sat, scsi or megaraid but ''${type}"
          -    exit
          -    ;;
          +  *) continue ;;
             esac
           done | format_output
        ''}"
      ];

      postPatch = ''
        patchShebangs ./
      '';
    };
  cfg = config;
in {
  imports = [
    <nixpkgs/nixos/modules/profiles/hardened.nix>
    <nixpkgs/nixos/modules/profiles/headless.nix>

    # https://github.com/NixOS/nixpkgs/issues/102137
    #<nixpkgs/nixos/modules/profiles/minimal.nix>

    ./base.nix
  ];

  security.allowUserNamespaces = lib.mkForce true;
  security.lockKernelModules = lib.mkForce true;
  boot.kernelModules = [
    "veth" # for containers
  ];
  boot.cleanTmpDir = true;

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
      "arp"
      "bonding"
      "conntrack"
      "cpu"
      "diskstats"
      "entropy" # "exec"
      "filefd"
      "filesystem"
      "hwmon"
      "loadavg"
      "mdadm"
      "meminfo"
      "netdev"
      "netstat"
      "sockstat"
      "systemd"
      "textfile"
      "time"
      "vmstat"
      "wifi"
      "zfs"
    ];
    extraFlags = [
      "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
      ""
    ];
  };
  services.cron.systemCronJobs = [
    "*/5 * * * * root ${node-exporter-textfile-collector-scripts}/bin/smartmon.sh | ${pkgs.moreutils}/bin/sponge /var/lib/prometheus-node-exporter-text-files/smartmon.prom"
  ];
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

  services.openssh.extraConfig = ''
    Banner /etc/sshd/banner-line
  '';

  environment.etc."sshd/banner-line".text = let
    text = config.networking.hostName;
    size = 80 - (lib.stringLength text);
    space = lib.fixedWidthString size " " "";
  in ''
    ────────────────────────────────────────────────────────────────────────────────
    ${space}${text}
  '';

  services.mysql = {
    bind = lib.mkDefault "::1";
    package = lib.mkDefault pkgs.mysql80;
  };
  services.mysqlBackup = {
    enable = (if cfg.services.mysql.enable then true else false);
  };

  security.acme.email = lib.mkDefault "seb@ds.ag";
  security.acme.acceptTerms = true;

  services.nginx = {
    recommendedGzipSettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;

    # https://ssl-config.mozilla.org/#server=nginx&config=intermediate
    # some android things shit their pants with TLS1.3 ....
    sslProtocols = lib.mkDefault "TLSv1.2 TLSv1.3";
    #sslDhparam = dhparam-file;
    sslCiphers = lib.mkDefault
      "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";

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
      listen = [{
        "addr" = "127.0.0.1";
        "port" = 80;
      }];

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
  systemd.services.prometheus-nginx-exporter.requires = [ "nginx.service" ];
  services.prometheus.scrapeConfigs = [{
    job_name = "nginx";
    scrape_interval = "60s";
    static_configs = [{ targets = [ "localhost:9113" ]; }];
  }];
}
