with import <nixpkgs> {};
with luaPackages;

let
  fennel = pkgs.writeScriptBin "fennel"
    ( builtins.readFile ( pkgs.fetchurl {
      url = "https://fennel-lang.org/downloads/fennel-0.5.0";
      sha256 = "1c0bbixc827id4k7gwgzypgc52xzcjld7w0ngsks734772a2lab5";
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
