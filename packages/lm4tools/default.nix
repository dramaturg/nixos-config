{ stdenv, fetchFromGitHub, pkgconfig, libusb }:

with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "lm4tools";
  
  src = fetchFromGitHub {
    owner = "utzig";
    repo = "lm4tools";
    rev = "61a7d17b85e9b4b040fdaf84e02599d186f8b585";
    sha256 = "1gbpl9v3spbrzzzm0g9fanjfgrjwbjrzwp02w0szknxsil5psgdd";
  };

  makeFlags = [
    "PREFIX=$(out)"
  ];


  buildInputs = [
    pkgconfig
    libusb
  ];

  meta = {
    description = "";
    homepage = https://github.com/utzig/lm4tools;
    # license = stdenv.lib.licenses.gpl2Plus;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}