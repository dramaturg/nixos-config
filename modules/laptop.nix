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
      echo '1' > '/sys/module/snd_hda_intel/parameters/power_save';
    '';
  };

  services.tlp.enable = true;
  services.tlp.settings = {
    "TLP_DEFAULT_MODE" = "BAT";
    "CPU_SCALING_GOVERNOR_ON_AC" = "performance";
    "CPU_SCALING_GOVERNOR_ON_BAT" = "ondemand";
  };
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

  boot.kernel.sysctl = {
    "vm.dirty_writeback_centisecs" = 1500;
  };

  hardware = {
    acpilight.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    pulseaudio = lib.mkForce {
      enable = true;

      # for bluetooth
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
    };
  };

  services.blueman.enable = true;
}
