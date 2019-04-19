{
  networking = {
    enableIPv6 = true;
    dhcpcd = {
      extraConfig = "slaac private";
    };
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.default.use_tempaddr" = 2;
    "net.ipv4.ip_forward" = 1;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };
}
