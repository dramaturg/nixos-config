{ pkgs, lib, ... }:
{
  imports = [
    ./workstation.nix
    ./wifi.nix
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
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
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=lock
    HandleLidSwitchDocked=ignore
  '';

  environment.systemPackages = with pkgs; [
    powertop
  ];

  hardware = {
    acpilight.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    pulseaudio = lib.mkForce {
      enable = true;

      # for bluetooth
      package = pkgs.pulseaudioFull;
    };
  };
}
