{ pkgs, lib, ... }: {
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

  environment.systemPackages = with pkgs; [ powertop ];

  boot.kernel.sysctl = { "vm.dirty_writeback_centisecs" = 1500; };

  hardware = {
    acpilight.enable = true;

    bluetooth = {
      enable = true;
      hsphfpd.enable = true;
      powerOnBoot = false;
      settings.General.AutoConnect = true;
    };

    pulseaudio = lib.mkForce {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };
  # Workaround: https://github.com/NixOS/nixpkgs/issues/114222
  systemd.user.services.telephony_client.enable = false;

  services.actkbd = {
    enable = true;
    bindings = [
      # "Phone connect"
      {
        keys = [ 56 125 218 ];
        events = [ "key" ];
        command =
          "${pkgs.pulseaudio}/bin/pactl set-card-profile bluez_card.AC:BD:70:5B:3E:B5 headset-head-unit";
      }

      # "Phone disconnect"
      {
        keys = [ 29 56 223 ];
        events = [ "key" ];
        command =
          "${pkgs.pulseaudio}/bin/pactl set-card-profile bluez_card.AC:BD:70:5B:3E:B5 a2dp-sink-aac";
      }
    ];
  };

  services.blueman.enable = true;
}
