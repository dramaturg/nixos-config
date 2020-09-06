with import <nixpkgs> {};
with luaPackages;

let
  fennel = pkgs.writeScriptBin "fennel"
    ( builtins.readFile ( pkgs.fetchurl {
      url = "https://fennel-lang.org/downloads/fennel-0.6.0";
      sha256 = "01f0xfp9g5z6jhdr006n15bnn0rlcfdbgiilamqgkhx28gnjrswf";
    }));

  libs = [
    lua
    cjson
    luasocket
    luasec
    readline
  ];
in
stdenv.mkDerivation rec {
  name = "lua-env";
  buildInputs = libs ++ [
    fennel
  ];

  shellHook = ''
    export LUA_CPATH="${lib.concatStringsSep ";" (map getLuaCPath libs)}"
    export LUA_PATH="${lib.concatStringsSep ";" (map getLuaPath libs)}"
  '';
}
