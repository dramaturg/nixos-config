{ config, pkgs, lib, ... }:
{
  imports = [
    ./server.nix
  ];

  services.prometheus = {
    enable = true;
    pushgateway.enable = lib.mkDefault false;
    #exporters.blackbox.enable = lib.mkDefault true;
    #exporters.node.enable = lib.mkDefault true;

    webExternalUrl = "https://grafana.sandkasten.ds.ag/prometheus/";
    #extraFlags = [
    #];

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{
            targets = [ config.services.prometheus.listenAddress ];
        }];
      }
      {
        job_name = "node";
        static_configs = [{
            targets = [
              "127.0.0.1:9100"
            ];
        }];
      }
    ];

    globalConfig = {
      scrape_interval = "60s";
      scrape_timeout  = "20s";
    };
  };
  systemd.services.prometheus = {
    after = [ "network-interfaces.target" ];
    wants = [ "network-interfaces.target" ];
  };

  services.grafana = {
    enable = true;
    domain = "grafana.sandkasten.ds.ag";
    addr = "127.0.0.1";
    security.adminUser = "admin";
    security.adminPasswordFile = /etc/nixos/secrets/grafana_admin_pass;
    auth.anonymous.enable = lib.mkDefault false;
    auth.anonymous.org_role = "Viewer";

    smtp = {
      enable = config.services.ssmtp.enable;
      host = config.services.ssmtp.hostName;
      user = config.services.ssmtp.authUser;
      passwordFile = config.services.ssmtp.authPassFile;
    };

    provision = {
      enable = true;
      datasources = [
        {
          name = "Prometheus";
          isDefault = true;
          type = "prometheus";
          url = "http://127.0.0.1:9090/prometheus/";
        }
      ];
      #dashboards = [
      #  "Node Exporter Full"
      #];
    };
  };
  systemd.services.grafana = {
    after = [ "network-interfaces.target" ];
    wants = [ "network-interfaces.target" ];
  };

  services.nginx.virtualHosts."grafana.sandkasten.ds.ag" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
    };

    locations."/prometheus" = {
      proxyPass = "http://127.0.0.1:9090";
    };
  };
}
