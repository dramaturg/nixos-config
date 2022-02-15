with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "pgmodeler-${version}";
  version = "0.9.1";

  isLibrary = false;
  isExecutable = true;
  
  src = fetchFromGitHub {
    owner = "pgmodeler";
    repo = "pgmodeler";
    rev = "3db789f411c8074da329a7624f0e3a1eadec9c68";
    sha256 = "15isnbli9jj327r6sj7498nmhgf1mzdyhc1ih120ibw4900aajiv";
  };

  nativeBuildInputs = [
    pkgconfig
    qt5.qmake
    qt5.qttools
  ];

  buildInputs = [
    libxml2
    postgresql.lib
  ];

  preConfigure = ''
    INCLUDE_DIR=${pkgs.postgresql}/include
    LIB_DIR=${pkgs.postgresql.lib}/lib
  '';

  configurePhase = ''
    qmake -r PREFIX=$out BINDIR=$out PRIVATEBINDIR=$out PRIVATELIBDIR=$out/lib pgmodeler.pro
  '';

  meta = {
    description = "PostgreSQL Database Modeler - is an open source data modeling tool designed for PostgreSQL";
    homepage = https://github.com/pgmodeler/pgmodeler;
    license = stdenv.lib.licenses.gpl3;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}
