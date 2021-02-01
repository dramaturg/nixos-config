{ pkgs, lib, config, ... }:

let
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
in
{
  imports = [
    ./server.nix
  ];

  environment.systemPackages = with pkgs; [
  ];

  services.quassel = {
    enable = true;
    interfaces = [ "0.0.0.0" ];
    #package = unstable.quasselDaemon;
    package = unstable.pkgs.quassel.override {
      monolithic = false;
      enableDaemon = true;
      withKDE = false;
      static = true;
      tag = "-daemon-qt5";
    };
    requireSSL = true;
    certificateFile = "${config.security.acme.certs."quassel.genf.ds.ag".directory}/combined.pem";
  };
  systemd.services.quassel = {
    after = [
      "network-interfaces.target"
      "acme-quassel.genf.ds.ag.service" ];
    wants = [
      "network-interfaces.target"
      "acme-quassel.genf.ds.ag.service" ];
  };

  services.nginx.enable = true;
  security.acme.certs."quassel.genf.ds.ag" = {
    group = "quassel";
  #  allowKeysForGroup = true;
  };
  users.groups."quassel".members= [ "nginx" ];
  services.nginx.virtualHosts."quassel.genf.ds.ag" = {
    forceSSL = true;
    enableACME = true;
    globalRedirect = "duckduckgo.com";
  };

  networking.firewall = {
    allowedTCPPorts = [
      config.services.quassel.portNumber
    ];
  };
}
