
let
  useGeodeOptimizations = stdenv: stdenv //
    { mkDerivation = args: stdenv.mkDerivation (args // {
        NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or "") +
          " -march=geode -Os -fno-align-jumps -fno-align-functions" +
          " -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer";
      });
    };
  nixpkgs = import <nixpkgs> {
    overlays = [
      (self: super: {
        stdenv = useGeodeOptimizations super.stdenv;
      })
    ];
  };
in
{
  #nixpkgs.config.packageOverrides = geodepkgs;
  nixpkgs.overlays = [
    (self: super: {
      stdenv = useGeodeOptimizations super.stdenv;
    })
  ];
}
