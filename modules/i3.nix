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

  renameWorkspace = pkgs.writeScriptBin "i3-rename-workspace.sh" ''
	#!${pkgs.bash}/bin/bash
    PATH=$PATH:${pkgs.jq}/bin:${pkgs.i3}/bin
	set -e
	num=`i3-msg -t get_workspaces | jq 'map(select(.focused == true))[0].num'`
	i3-input -F "rename workspace to \"$num:%s\"" -P 'New name: '
	name=`i3-msg -t get_workspaces | jq 'map(select(.focused == true))[0].name'`
	# If empty name was set
	if [[ "$name" =~ ^\"[0-9]+:\"$ ]]
	then
	  # Remove trailing colon and whitespace
	  i3-msg "rename workspace to \"$num\""
	fi
  '';

  monitorSelect = pkgs.writeScriptBin "xrandr-change.sh" ''
    #!${pkgs.stdenv.shell}
    export PATH="${with pkgs; lib.makeBinPath [xorg.xrandr findutils rofi coreutils pythonPackages.python gnugrep]}"
    set -e
    state="$(xrandr)";
    outputs="$(awk '{if ($2 == "connected") print $1}' <<< "$state")"
    function getModes() {
        awk -v output=$1 '{if ($1 == output) {getline; while ($0 ~ /^\ \ /) {print $1; getline;}}}' <<< "$state"
    }
    function getMode() {
        echo "$((echo auto; getModes "$1";) | rofi -dmenu -p "Select mode for $1 output")"
    }
    function getPosition() {
        output="$1"
        relationTo="$2"
        echo "$((echo -e "$output same-as $relationTo\n$output left-of $relationTo\n$output right-of $relationTo\n$output above $relationTo\n$output below $relationTo";) | rofi -dmenu -p "Select $output output relation to $relationTo output")"
    }
    function permutations() {
        python -c "import sys, itertools; a=sys.argv[1:]; print('\n'.join('\n'.join(' '.join(str(i) for i in c) for c in itertools.permutations(a, i)) for i in range(1, len(a)+1)))" "$@";
    }
    entries="$(permutations $outputs | rofi -dmenu -p "Select output combination (first one is primary)" | tr ' ' '\n')"
    flags=""
    primary="$(head -n 1 <<< "$entries")"
    if [[ -z "$entries" ]]
    then
        echo "No Selection" >&2
        exit 1
    fi
    for output in $outputs
    do
        if echo "$entries" | grep -Eq "^''${output}$"
        then
            mode="$(getMode $output)"
            if [ "$mode" == "auto" ] || [ -z "$mode" ]
            then
                modeFlag="--auto"
            else
                modeFlag="--mode $mode"
            fi
            if [ "$primary" == "$output" ]
            then
                flags="$flags --output $output --primary $modeFlag"
            else
                positionFlag="$(getPosition $output $primary | awk '{printf "--"$2" "$3}')"
                flags="$flags --output $output $modeFlag $positionFlag"
            fi
        else
            flags="$flags --output $output --off"
        fi
    done
    xrandr $flags
  '';

  reclassAppWindow = pkgs.writeScriptBin "reclass-app-window.sh" ''
    #!${pkgs.stdenv.shell}
    new_class=$1
    shift
    $@ &
    pid="$!"
    trap 'kill -TERM $pid; wait $pid' TERM INT
    # Wait for the window to open and grab its window ID
    winid=""
    while : ; do
      ps --pid $pid &>/dev/null || exit 1
      winid="`${pkgs.wmctrl}/bin/wmctrl -lp | ${pkgs.gawk}/bin/awk -vpid=$pid '$3==pid {print $1; exit}'`"
      [[ -z "$winid"  ]] || break
    done
    ${pkgs.xdotool}/bin/xdotool set_window --class $new_class $winid
    wait $pid
  '';

  exposeWorkspace = pkgs.writeScriptBin "i3-expose-workspace.sh" ''
    #!${pkgs.stdenv.shell}
    export WORKSPACE=''${WORKSPACE:-$(i3-msg -t get_workspaces  | ${pkgs.jq}/bin/jq '.[] | select(.focused==true).name | split(":") | .[1]' -r)}
    if [ "$WORKSPACE" == "null" ]; then
      unset WORKSPACE
    fi
    exec $@
  '';

  cfg = config;
  unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  unstable = import unstableTarball {
    config = removeAttrs config.nixpkgs.config [ "packageOverrides" ];
  };
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
      renameWorkspace monitorSelect reclassAppWindow exposeWorkspace
      pavucontrol pasystray
    ];

    environment.etc = {
      "i3/i3status".source = builtins.toPath ("/etc/nixos/dotfiles/i3/" + (cfg.i3statusConfigFile));
    };

    security.pam.services.lightdm.enableGnomeKeyring = true;

    services.xserver = {
      displayManager = {
        defaultSession = "xfce+i3";
        sessionCommands = ''
          export TERMINAL=termite

          xset s 600 0
          xset r rate 440 50
          xss-lock -l -- i3lock -c b31051 -n &
        '';
      };
      desktopManager = {
        xterm.enable = false;

        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      windowManager = {
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
