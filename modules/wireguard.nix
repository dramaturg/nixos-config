{ config, pkgs, lib, ... }:
let
  wireguardIsServer = lib.mkDefault false;
in
{
  # wg genkey > /etc/nixos/secrets/wireguard_private
  # wg pubkey < /etc/nixos/secrets/wireguard_private > /etc/nixos/secrets/wireguard_public
  # chmod 600 /etc/nixos/secrets/wireguard_*

  imports = [
    ./base.nix
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

  environment.systemPackages = with pkgs; [
    wireguard
    wireguard-tools
  ];

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "172.18.55.2/24" ];
      privateKeyFile = "/etc/nixos/secrets/wireguard_private";

      peers = [
        {
          publicKey = "9ok3iCwsXAY05UvL7qzf3uDj3rb8NC/HMhvPNN2S9Hs=";
          #allowedIPs = [ "0.0.0.0/0" ];
          allowedIPs = [ "172.18.55.0/24" ];
          endpoint = "felsenberg.ds.ag:51555";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  networking.extraHosts = ''
    172.18.55.1 felsenberg.wireg
    172.18.55.2 woodstock.wireg
    172.18.55.57 sandkasten.wireg
  '';
}
