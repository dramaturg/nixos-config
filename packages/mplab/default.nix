{ stdenv, fetchFromGitHub, pkgconfig, libusb }:

with import <nixpkgs> {};

let
	version = 5.05;

#	rpath = stdenv.lib.makeLibraryPath [
#	] + ":${stdenv.cc.cc.lib}/lib64";

in stdenv.mkDerivation {
  name = "mplab-${version}";

  src = fetchurl {
	  url = "http://ww1.microchip.com/downloads/en/DeviceDoc/MPLABX-v${version}-linux-installer.tar";
	  sha256 = "";
  };
  
  buildInputs = [
  ];

  meta = {
    description = "Microchip microcontroller and DSP IDE";
    homepage = https://www.microchip.com/mplab/mplab-x-ide;
    license = licenses.unfree;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}