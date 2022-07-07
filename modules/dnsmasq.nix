{ config, ... }:
{
  # Local DNS server
  services.dnsmasq = {
    enable = true;
    servers = [
      "209.244.0.3"
      "209.244.0.4"
      "208.67.222.222"
      "208.67.220.220"
      "1.1.1.1"
      "9.9.9.9"
      "8.8.8.8"
      "8.8.4.4"
    ];
    extraConfig = ''
      address=/service.consul/127.0.0.1
      listen-address=127.0.0.1,172.17.0.1
      host-record=postgres,127.0.0.1
    '';
  };

  networking.networkmanager.dns = "none";
}