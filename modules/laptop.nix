{ pkgs, lib, ... }:
{
  imports = [
    ./workstation.nix
  ];

  powerManagement = {
    enable = true;
    powerUpCommands = ''
      echo '1500' > '/proc/sys/vm/dirty_writeback_centisecs';
      echo '1' > '/sys/module/snd_hda_intel/parameters/power_save';
    '';
  };

  services.tlp.enable = true;
  services.upower.enable = true;

  services.logind.extraConfig = ''
    IdleAction=lock
    IdleActionSec=30s
  '';
  services.logind.lidSwitch = "suspend";

  environment.systemPackages = with pkgs; [
    powertop
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  hardware.pulseaudio = lib.mkForce {
    enable = true;

    # for bluetooth
    package = pkgs.pulseaudioFull;
  };
}
