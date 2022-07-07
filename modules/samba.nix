
services.samba = {
  enable = true;
  securityType = "share";
  extraConfig = ''
    workgroup = WORKGROUP
    server string = smbnix
    netbios name = smbnix
    security = share
    #use sendfile = yes
    #max protocol = smb2
    hosts allow = 192.168.0  localhost
    hosts deny = 0.0.0.0/0
    guest account = nobody
    map to guest = bad user
  '';
  shares = {
    public = {
      path = "/mnt/Shares/Public";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "username";
      "force group" = "groupname";
    };
    private = {
      path = "/mnt/Shares/Private";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "username";
      "force group" = "groupname";
    };
  };
};

networking.firewall.allowedTCPPorts = [ 445 139 ];
networking.firewall.allowedUDPPorts = [ 137 138 ];

networking = {
  firewall = {
    allowedTCPPorts = [
      445  # Samba
    ];
    allowedTCPPortRanges = [
      { from = 137;  to = 139; }   # Samba
    ];
    autoLoadConntrackHelpers = true;
    connectionTrackingModules = [ "netbios_ns" ];
    extraCommands = ''
      iptables -t raw -A OUTPUT -d 192.168.0.0/16 -p udp -m udp --dport 137 -j CT --helper netbios-ns
    '';
    extraStopCommands = ''
      iptables -t raw -D OUTPUT -d 192.168.0.0/16 -p udp -m udp --dport 137 -j CT --helper netbios-ns
    '';
  };
};