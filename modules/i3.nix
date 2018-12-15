{ lib, config, ... }:
{
  services.xserver = {
    displayManager = {
      sessionCommands = ''
          xset s 600 0
          xset r rate 440 50
          xss-lock -l -- i3lock -c b31051 -n &
          ${pkgs.networkmanagerapplet}/bin/nm-applet &
      '';
    };
    desktopManager = {
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager = {
      default = "i3";
      i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3lock
          i3status
          feh
          networkmanager_dmenu
          termite
          xautolock
        ];
        configFile = "/etc/nixos/dotfiles/i3/config";
      };
    };
  };

#  stdenv.mkDerivation {
#    name = "i3-winmenu";
#    buildInputs = [
#      (pkgs.python36.withPackages (pythonPackages: with pythonPackages; [
#        i3
#      ]))
#    ];
#    unpackPhase = "true";
#    installPhase = ''
#      mkdir -p $out/bin
#      cp ${../scripts/i3-winmenu.py} $out/bin/i3-winmenu.py
#      chmod +x $out/bin/i3-winmenu.py
#    '';
#  };
}
