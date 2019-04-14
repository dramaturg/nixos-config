
with import <nixpkgs> {};

let
  version = "0.9.0";
in

stdenv.mkDerivation rec {
  name = "s2geometry-${version}";

  src = fetchFromGitHub {
    owner = "google";
    repo = "s2geometry";
    rev = "4ad31e9b9d4b25f0ddffa2061ac5a7d14edf7195";
    sha256 = "1mx61bnn2f6bd281qlhn667q6yfg1pxzd2js88l5wpkqlfzzhfaz";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    glog
    gflags
    gtest
    openssl
    swig
    python3
  ];
  cmakeFlags = [
    "-DWITH_GFLAGS=ON"
    "-DWITH_GLOG=ON"
  ];

  meta = {
    description = "S2 is a library for spherical geometry that aims to have the same robustness, flexibility, and performance as the very best planar geometry libraries.";
    homepage = http://s2geometry.io;
    license = stdenv.lib.licenses.asl20; # Apache License 2.0
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}
