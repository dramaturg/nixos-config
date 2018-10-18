{ writeText, theme }:

let
  self = writeText "i3status-config"
    ''
      general {
      	colors = true
      	interval = 5
      
      	color_good = "#1EAB36"
      	color_degraded = "#8c7f22"
      	color_bad = "#be2422"
      }
      
      order += "ipv6"
      #order += "path_exists VPN"
      order += "wireless wlp1s0"
      order += "battery 0"
      order += "volume master"
      order += "tztime singapore"
      order += "tztime newyork"
      order += "time"
      
      wireless wlp1s0 {
      	format_up = "W: (%quality at %essid, %bitrate) %ip"
      	format_down = "W: down"
      }
      
      battery 0 {
              format = "%percentage"
      	low_threshold = 15
              path = "/sys/class/power_supply/max170xx_battery/uevent"	
      }
      
      run_watch DHCP {
      	pidfile = "/var/run/dhclient*.pid"
      }
      
      #run_watch VPN {
      #	pidfile = "/var/run/vpnc/pid"
      #}
      
      #path_exists VPN {
      #	path = "/proc/sys/net/ipv4/conf/vpn0"
      #}
      
      tztime newyork {
      	format = "%H:%M:%S %Z"
      	timezone = "America/New_York"
      }
      
      tztime singapore {
      	format = "%H:%M:%S %Z"
      	timezone = "Asia/Singapore"
      }
      
      volume master {
      	format = " Vol: %volume "
      	device = "default"
      	mixer = "Master"
      	mixer_idx = 0
      }
      
      time {
      	format = "%a %b %d, %H:%M"
      }
    '';
