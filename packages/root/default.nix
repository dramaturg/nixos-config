
with import <nixpkgs> {};

let
  version = "6.04.00-patches";
  rev = "c16a0eb67e8a320e16e725c159e386e1dbed4711";
in

stdenv.mkDerivation rec {
  name = "root-${version}";
  isLibrary = true;
  isExecutable = true;

  src = fetchgit {
    url = "https://github.com/root-project/root.git";
    rev = "${rev}";
    sha256 = "1sgwiqdnb7l0vsfwxasijwfj436rxzqfzp124biw7g86gfcm6wa0";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    cfitsio
    fftw
    ftgl
    glew
    graphviz
    gsl
    libGL
    libxml2
    pcre
    python3
    python3Packages.numpy
    qt4
    xorg.libX11
    xorg.libXext
    xorg.libXft
    xorg.libXpm
    lzma
    libpng
    libtiff
    libjpeg
    avahi
    pythia
    sqlite
  ];

  preConfigure = ''
    patchShebangs ./configure
  '';

  cmakeFlags = [
    "-Wno-dev"
    "-Dbuiltin_xrootd=on"
  ];

  meta = {
    description = "A modular scientific software toolkit. It provides all the functionalities needed to deal with big data processing, statistical analysis, visualisation and storage.";
    homepage = https://root.cern.ch;
    license = stdenv.lib.licenses.lgpl21;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}
