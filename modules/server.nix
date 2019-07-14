{ pkgs, lib, config, ... }:
{
  imports = [
    ./base.nix
  ];

  fail2ban.enable = true;
  fail2ban.jails.ssh-iptables = ''
    enabled = true
  '';
}