{ lib, config, pkgs, ... }:
let
  i3-winmenu = pkgs.stdenv.mkDerivation {
    name = "i3-winmenu";
    buildInputs = [
      (pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
        i3-py
      ]))
    ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp ${../scripts/i3-winmenu.py} $out/bin/i3-winmenu
      chmod +x $out/bin/i3-winmenu
    '';
  };
  cfg = config;
in
{
  options = {
    i3statusConfigFile = lib.mkOption {
      default = "i3status";
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      i3 i3lock dmenu i3-winmenu
      pavucontrol pasystray
    ];

    environment.etc = {
      "i3/i3status".source = builtins.toPath ("/etc/nixos/dotfiles/i3/" + (cfg.i3statusConfigFile));
    };

    services.xserver = {
      displayManager = {
        lightdm = {
          enable = true;
          greeters.gtk = {
            theme.package = pkgs.zuki-themes;
            theme.name = "Zukitre";
          };
        };
        sessionCommands = ''
          export TERMINAL=termite

          xset s 600 0
          xset r rate 440 50
          xss-lock -l -- i3lock -c b31051 -n &
          ${pkgs.networkmanagerapplet}/bin/nm-applet &
        '';
      };
      desktopManager = {
        default = "xfce";
        xterm.enable = false;

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
            i3-winmenu
          ];
          configFile = "/etc/nixos/dotfiles/i3/config";
        };
      };
    };
  };
}
