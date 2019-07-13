{ pkgs, lib, config, configName, ... }:
{
  networking = {
    wireless = {
      enable = (if config.services.xserver.enable then false else true);
      iwd.enable = (if config.services.xserver.enable then false else true);
      networks = {
        Kunterbunt = { psk = "xxx"; };
      };
    };
    networkmanager = {
      enable = (if config.services.xserver.enable then true else false);
      unmanaged = [ "vboxnet0" "virbr0" "virbr0-nic" "docker0" ];
      packages = [
        pkgs.networkmanager-openvpn
        pkgs.networkmanagerapplet
        pkgs.networkmanager_dmenu
      ];
    };
  };
}
