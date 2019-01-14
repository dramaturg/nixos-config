{ pkgs, lib, ... }:
{
  imports = [
    ./workstation.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  powerManagement = {
    enable = true;
    #scsiLinkPolicy = "min_power";
    powerUpCommands = ''
      echo 'min_power' > '/sys/class/scsi_host/host0/link_power_management_policy';
      echo '1500' > '/proc/sys/vm/dirty_writeback_centisecs';
      echo '1' > '/sys/module/snd_hda_intel/parameters/power_save';
      echo 'min_power' > '/sys/class/scsi_host/host1/link_power_management_policy';
      echo 'min_power' > '/sys/class/scsi_host/host2/link_power_management_policy';
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
