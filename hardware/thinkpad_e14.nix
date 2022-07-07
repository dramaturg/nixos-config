{ pkgs, lib, config, ... }:

let
  hardwareTarball = fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in
{
  imports = [
    ./intel-generic.nix
    ./intel-graphics.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    (hardwareTarball + "/lenovo/thinkpad/e14")
  ];

  #hardware.trackpoint = {
  #  enable = true;
  #  sensitivity = 220;
  #  speed = 0;
  #  emulateWheel = true;
  #};

  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  powerManagement = {
    powerUpCommands = ''
      echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
    '';
  };
}
