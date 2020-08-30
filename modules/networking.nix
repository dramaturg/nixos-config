{ lib, ... }:
{
  networking = {
    enableIPv6 = true;
    dhcpcd = {
      extraConfig = "slaac private";
    };
    firewall = {
      enable = true;
      logRefusedConnections = lib.mkDefault false;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.default.use_tempaddr" = 2;
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.tcp_min_snd_mss" = 536;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };
}
