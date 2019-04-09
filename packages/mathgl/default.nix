
with import <nixpkgs> {};

let
  version = "2.4.3";
  rev = "1607";
in

stdenv.mkDerivation rec {
  name = "mathgl-${version}";
  isLibrary = true;
  isExecutable = false;

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/mathgl/code/mathgl-2x";
    rev = "${rev}";
    sha256 = "108wxvfddig60hsjxvn2f7r00rxa5gzmhs51zyzhjgay6isgh7qr";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
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
    license = stdenv.lib.licenses.lgpl;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}
