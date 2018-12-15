{ stdenv, fetchFromGitHub, cmake, gflags, glog, gtest, openssl }:

{
  pkgs ? import <nixpkgs> {},
  stdenv ? pkgs.stdenv
}:

stdenv.mkDerivation rec {
  name = "s2geometry";
  
  src = fetchFromGitHub {
    owner = "google";
    repo = "s2geometry";
    rev = "b8c45b5d739fe0263fec3b5fd182bcd1e1ea0fea";
    sha256 = "0fjrgibdcsj71h88njxbdzrc2w1rd26qwbwazvzip2fxsifh8sz0";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    glog
    gflags
    gtest
    openssl
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
