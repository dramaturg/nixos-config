{config, pkgs, lib, ...}:

let
  optimizeWithFlags = pkg: flags:
    pkgs.lib.overrideDerivation pkg (old:
    let
      newflags = pkgs.lib.foldl' (acc: x: "${acc} ${x}") "" flags;
      oldflags = if (pkgs.lib.hasAttr "NIX_CFLAGS_COMPILE" old)
        then "${old.NIX_CFLAGS_COMPILE}"
        else "";
    in
    {
      NIX_CFLAGS_COMPILE = "${oldflags} ${newflags}";
    });
  useGeodeOptimizations = stdenv: stdenv //
    { mkDerivation = args: stdenv.mkDerivation (args // {
        NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or "") +
          " -march=geode -mtune=geode -O3 -fno-align-jumps -fno-align-functions" +
          " -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer";
        #stdenv = overrideCC stdenv gcc6;
      });
    };
  optimizeForGeode = pkg:
    optimizeWithFlags pkg [
      "-march=geode"
      "-mtune=geode"
      "-O3"
      "-fno-align-jumps"
      "-fno-align-functions"
      "-fno-align-labels"
      "-fno-align-loops"
      "-pipe"
      "-fomit-frame-pointer"
    ];
  #nixpkgs = import <nixpkgs> {
  #  overlays = [
  #    (self: super: {
  #      stdenv = useGeodeOptimizations super.stdenv;
  #    })
  #  ];
  #};
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    nix = optimizeForGeode pkgs.nix;
    boost = optimizeForGeode pkgs.boost;
  };

  #nixpkgs.config.packageOverrides = geodepkgs;
  #nixpkgs.overlays = [
  #  (self: super: {
  #    stdenv = optimizeForGeode super.stdenv;
  #  })
  #];
}
