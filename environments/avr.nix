#with import <nixpkgs> {};
with import ~/nixpkgs {};
pkgsCross.avr.stdenv.mkDerivation {
  name = "env";

  buildPackages = [
    pkgs.figlet
    pkgs.lolcat
  ];

  shellHook = ''
    figlet "AVR" | lolcat --freq 0.5
  '';
}