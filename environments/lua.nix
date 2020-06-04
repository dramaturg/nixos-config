with import <nixpkgs> {};
with luaPackages;

let
  fennel = pkgs.writeScriptBin "fennel"
    ( builtins.readFile ( pkgs.fetchurl {
      url = "https://fennel-lang.org/downloads/fennel-0.4.1";
      sha256 = "1lsgvnwi9dr63vx7lbzgpz326zq63rlagwfk8vi5jflvdfpnh7b0";
    }));

  libs = [
    lua
    cjson
    luasocket
    luasec
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
