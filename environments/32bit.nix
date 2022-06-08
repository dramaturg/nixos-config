with import <nixpkgs> {};

{ config, lib, pkgs, ... }:

let
  self = rec {
    callPackage = pkgs.lib.callPackageWith (pkgs // self);
    callPackage_i686 = pkgs.lib.callPackageWith (pkgs.pkgsi686Linux // self);
    fakechroot32 = callPackage_i686 <nixos/pkgs/tools/system/fakechroot> {};
  };
in with lib; {
  nativeBuildInputs = [ glibc_multi fakechroot32 utillinux ];

  buildPackages = [
    pkgs.figlet
    pkgs.lolcat
  ];

  shellHook = ''
    figlet "32bit" | lolcat --freq 0.5
  '';
}
