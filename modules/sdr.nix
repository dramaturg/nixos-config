{ pkgs, lib, config, fetchPypi, ... }:
let
  unstable = import <unstable> {};
in
{
  imports = [
    ./workstation.nix
  ];

  environment.systemPackages = with pkgs; [
    gnuradio
    gnuradio-osmosdr
    gnuradio-rds
    gnuradio-nacl
  ];
}
