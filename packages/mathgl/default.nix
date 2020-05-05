{ stdenv, pkgs, fetchsvn }:

stdenv.mkDerivation rec {
  pname = "mathgl";
  version = "2.4.5";
  isLibrary = true;
  isExecutable = false;

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/mathgl/code/mathgl-2x";
    rev = "1644";
    sha256 = "1caf92v02gjdx6p4ssza898a12pavzih8z9xxjhli32idcgz01gz";
  };

  nativeBuildInputs = with pkgs; [ cmake ];
  buildInputs = with pkgs; [
    fltk
    freeglut
    libGL
    libGLU
    libjpeg
    libpng
    zlib
  ];

  cmakeFlags = [
    "-Denable-fltk=on"
    "-Denable-glut=on"
    "-Denable-jpeg=on"
    "-Denable-lgpl=on"
    "-Denable-png=on"
  ];

  meta = {
    description = "a library for making high-quality scientific graphics";
    homepage = http://mathgl.sourceforge.net/doc_en/Main.html;
    license = stdenv.lib.licenses.gpl2;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}
