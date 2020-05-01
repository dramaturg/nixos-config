{ config, pkgs, lib, ... }:
let
  wireguardIsServer = lib.mkDefault false;
in
{
  # wg genkey > /etc/nixos/secrets/wireguard_private
  # wg pubkey < /etc/nixos/secrets/wireguard_private > /etc/nixos/secrets/wireguard_public
  # chmod 600 /etc/nixos/secrets/wireguard_*
  #
  # ssh felsenberg "wg set wg0 peer <pubkey> allowed-ips 172.18.55.2/32"

  imports = [
    ./base.nix
  ];

  environment.systemPackages = with pkgs; [
    wireguard
    wireguard-tools
  ];

  # config.networking.nat = {
  #   enable = true;
  #   externalInterface = "eth0";
  #   internalInterfaces = [ "wg0" ];
  # };
  # 
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  # 
  #   extraCommands = ''
  #     iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
  #   '';
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "172.18.55.57/24" ];
      listenPort = 51820;
      privateKeyFile = "/etc/nixos/secrets/wireguard_private";

      peers = [
        { # felsenberg
          publicKey = "9ok3iCwsXAY05UvL7qzf3uDj3rb8NC/HMhvPNN2S9Hs=";
          allowedIPs = [ "172.18.55.1/32" ];
          endpoint = "felsenberg.ds.ag:51555";
          persistentKeepalive = 25;
        }
        { # woodstock
          publicKey = "fFvx441OJ99/vJ1v3tcFc5kxw3EzBwrRSrzCPvw8NS4=";
          allowedIPs = [ "172.18.55.2/32" ];
        }
        { # zwerg
          publicKey = "Hf5WmvLuhpVKRC16ZqOfx6r1dQ4qa29GGmklCnNkWUI=";
          allowedIPs = [ "172.18.55.3/32" ];
        }
        { # sandkasten
          publicKey = "n/PJilqd0LplHSNVLgSSyH6s4PVE5cMCmK8uvoUwcAY=";
          allowedIPs = [ "172.18.55.57/32" ];
        }
      ];
    };
  };

  networking.extraHosts = ''
    172.18.55.1 felsenberg.wireg
    172.18.55.2 woodstock.wireg
    172.18.55.3 zwerg.wireg
    172.18.55.57 sandkasten.wireg
  '';
}
