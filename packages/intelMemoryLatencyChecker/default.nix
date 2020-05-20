{ stdenv, lib, fetchurl, autoPatchelfHook }:

with import <nixpkgs>{};

let platforms = [ "i686-linux" "x86_64-linux" ]; in
assert lib.elem stdenv.hostPlatform.system platforms;

stdenv.mkDerivation rec {
  pname = "intelMemoryLatencyChecker";
  version = "3.8";

  src = fetchurl {
    url = "http://software.intel.com/content/dam/develop/external/us/en/protected/mlc_v${version}.tgz";
    sha256 = "19gw8w11jpbs4pkkzkk6whx42mnkv8dv74f9wh5ql2lkpnvpz6ni";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];
  unpackPhase = ''
    tar xf $src Linux
  '';

  installPhase = ''
    install -m755 -D Linux/mlc $out/bin/mlc
  '';

  meta = {
    description = "";
    homepage    = https://software.intel.com/content/www/us/en/develop/articles/intelr-memory-latency-checker.html;
    #license     = stdenv.lib.licenses.;
    maintainers = [ "Sebastian Krohn <sebastian.krohn@ds.ag" ];
  };
}


