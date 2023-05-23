{ pkgs, lib, ... }: {
  imports = [ ./workstation.nix ./wifi.nix ];

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

  services.logind = {
    # config for lid close action
    # 1. if laptop is docked or powered, ignore the lid close
    # 2. otherwise it will suspend and hibernate, leaves 60s
    #    for dock or plugin the power
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "lock";
    extraConfig =
      "\n      IdleAction=lock\n      IdleActionSec=30s\n      HoldoffTimeoutSec=60\n    ";
  };

  environment.systemPackages = with pkgs; [ powertop ];

  boot.kernel.sysctl = { "vm.dirty_writeback_centisecs" = 1500; };

  hardware = {
    acpilight.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  services.blueman.enable = true;
}
