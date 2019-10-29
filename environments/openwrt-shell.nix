{ pkgs ? import <nixpkgs> {} }:

let
  openwrt-env = pkgs.buildFHSUserEnv {
    name = "openwrt";
    targetPkgs = pkgs: with pkgs; [
      which  # NASTY FUCKER all over
      pkgconfig  # (make menuconfig -> ncurses)

      autoconf
      automake
      gcc
      gnumake
      perl
      python2

      bash
      binutils  # ar
      bzip2
      file
      findutils
      gawk
      getopt
      gitAndTools.git
      gnugrep
      gnutar
      patch
      unzip
      wget

      ncurses.dev
    ];
  };

in

openwrt-env.env