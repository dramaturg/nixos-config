with import <nixpkgs> {};
with luaPackages;

let
  fennel = pkgs.writeScriptBin "fennel"
    ( builtins.readFile ( pkgs.fetchurl {
      url = "https://fennel-lang.org/downloads/fennel-0.7.0";
      sha256 = "1j521x3qqxvrfard26abb1hpvfh9y245ha0kn4hz0cpmyqsw92q6";
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
