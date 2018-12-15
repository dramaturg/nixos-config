{ stdenv, fetchFromGitHub, pkgconfig, libusb }:

with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "stm8flash";
  
  src = fetchFromGitHub {
    owner = "vdudouyt";
    repo = "stm8flash";
    rev = "f3f547b410f21d9a5f957d6ec1bfbb28642966cf";
    sha256 = "0fc7lkffxx8zyb6m6gmw78knv9v9p04kjjhy7304y84vmhk6xawq";
  };

  makeFlags = [
    "DESTDIR=$(out)"
    "RELEASE=foobar"
  ];

  buildInputs = [
    pkgconfig
    libusb
  ];

  postInstall = ''
    cd $out
    mkdir -p bin
    mv usr/local/bin/stm8flash bin
    rmdir -p usr/local/bin
  '';

  meta = {
    description = "program your stm8 devices with SWIM/stlinkv(1,2)";
    homepage = https://github.com/vdudouyt/stm8flash;
    license = stdenv.lib.licenses.gpl2Plus;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}