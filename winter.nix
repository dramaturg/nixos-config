{ config, ... }:
{
  imports = [
    ./hardware/intel-generic.nix
    ./modules/server.nix
    #./modules/ampache.nix
  ];

  networking.hostName = "winter";

  boot.initrd.kernelModules = [ "dm_snapshot" ];

  security.allowUserNamespaces = true;
  security.allowSimultaneousMultithreading = true;

  #nix.useSandbox = true;
  nix.buildCores = 0; # 0 is auto detection

  programs.mosh.enable = true;
  programs.mtr.enable = true;

  users.mutableUsers = false;

  networking.firewall.allowedTCPPorts = [
    22
    80 443
  ];
}
