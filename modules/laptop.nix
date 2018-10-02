{ pkgs, lib, ... }:
{
  imports = [
    ./workstation.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  services.tlp.enable = true;

  services.logind.extraConfig = ''
    IdleAction=suspend
    IdleActionSec=30s
    HandlePowerKey=suspend
  '';

  environment.systemPackages = with pkgs; [
    networkmanager
  ];

  networking = {
    networkmanager = {
      enable = true;
    };
  };

  hardware.bluetooth = {
    enable = true;
  };

  hardware.pulseaudio = lib.mkForce {
    enable = true;

    # for bluetooth
    package = pkgs.pulseaudioFull;

    configFile = pkgs.writeText "default.pa" ''
      load-module module-bluetooth-policy
      load-module module-bluetooth-discover
    '';

    extraConfig = "
     [General]
     Enable=Source,Sink,Media,Socket
    ";
  };
}
