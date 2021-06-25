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
}
