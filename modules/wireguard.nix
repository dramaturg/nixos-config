{ config, pkgs, lib, ... }:
let
  cfg = config;
  wireguardIsServer = lib.mkDefault false;
in
{
  # wg genkey > /etc/nixos/secrets/wireguard_private
  # wg pubkey < /etc/nixos/secrets/wireguard_private > /etc/nixos/secrets/wireguard_public
  # chmod 600 /etc/nixos/secrets/wireguard_*
  #
  # ssh felsenberg "wg set wg0 peer <pubkey> allowed-ips 172.18.55.2/32"

  options = {
    wgInterface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };
    wgIP = lib.mkOption {
      type = lib.types.str;
    };
    wgPrivateKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos/secrets/wireguard_private";
    };
    wgIPRange = lib.mkOption {
      type = lib.types.int;
      default = 24;
    };
    wgListenPort = lib.mkOption {
      type = lib.types.int;
      default = 51820;
    };
    wgPeers = lib.mkOption {
      type = with lib.types; listOf (submodule config.networking.wireguard.peerOpts);
    };
  };

  config = {
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
      allowedUDPPorts = [ cfg.wgListenPort ];
    #   extraCommands = ''
    #     iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
    #   '';
    };

    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "${cfg.wgIP}/${cfg.wgIPRange}" ];
        listenPort = cfg.wgListenPort;
        privateKeyFile = cfg.wgPrivateKeyFile;

        peers = [ cfg.wgPeers ];
      };
    };
  };
}
