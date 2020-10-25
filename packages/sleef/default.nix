{ stdenv, fetchFromGitHub, lib, cmake }:

stdenv.mkDerivation rec {
  name = "sleef";
  
  src = fetchFromGitHub {
    owner = "shibatch";
    repo = "sleef";
    rev = "3.5.1";
    sha256 = "1jybqrl2dvjxzg30xrhh847s375n2jr1pix644wi6hb5wh5mx3f7";
  };

  buildInputs = [ cmake ];

  meta = {
    description = "SLEEF Vectorized Math Library";
    homepage = https://sleef.org;
    license = stdenv.lib.licenses.bsl11;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}
