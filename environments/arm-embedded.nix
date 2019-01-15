#with import <nixpkgs> {};
with import ~/nixpkgs {};
pkgsCross.arm-embedded.stdenv.mkDerivation {
  name = "env";
  buildPackages = [];
}