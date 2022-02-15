#{ config, lib, pkgs, ... }:
with import <nixpkgs> {};

let
  gnat = lib.overrideDerivation pkgs.gcc9.cc.override {
  };
in pkgs.stdenv.mkDerivation {
  name = "ada-shell";
  nativeBuildInputs = [gnat];
  #shellHook = "exec julia-fhs";
}



