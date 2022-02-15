#{ stdenv, fetchFromGitHub, pkgconfig, cmake }:

with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "gmmlib";
  version = "18.4.1";
  isLibrary = true;
  isExecutable = false;
  
  src = fetchFromGitHub {
    owner = "intel";
    repo = "gmmlib";
    rev = "413896ed8e7ead3dd1c0fea9a4fe7f8326b7b9ff";
    sha256 = "1nxbz54a0md9hf0asdbyglvi6kiggksy24ffmk4wzvkai6vinm17";
  };

  nativeBuildInputs = [ cmake ];

  preConfigure = ''
    cmakeFlags="-DCMAKE_BUILD_TYPE=Release"
  '';

  meta = {
    description = "The Intel(R) Graphics Memory Management Library provides device specific and buffer management for the Intel(R) Graphics Compute Runtime for OpenCL(TM) and the Intel(R) Media Driver for VAAPI";
    homepage = https://github.com/intel/gmmlib;
    license = stdenv.lib.licenses.mit;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}