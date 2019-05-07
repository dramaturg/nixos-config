with import <nixpkgs> {};

let
  name = "guile-charting-${version}";
  version = "0.2.0";
in stdenv.mkDerivation {
  inherit name;

  src = fetchurl {
    url = "http://wingolog.org/pub/guile-charting/${name}.tar.gz";
    sha256 = "0w5qiyv9v0ip5li22x762bm48g8xnw281w66iyw094zdw611pb2m";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    guile
    guile-cairo
    cairo
  ];

  meta = with stdenv.lib; {
    description = "Guile-Charting is a library to create charts and graphs in Guile";
    homepage = "http://wingolog.org/projects/guile-charting/";
    license = licenses.lgpl3Plus;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
    platforms = platforms.gnu ++ platforms.linux;
  };
}
