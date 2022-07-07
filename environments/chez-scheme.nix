with import <nixpkgs> {};

let
in
stdenv.mkDerivation rec {
  name = "chez-scheme";
  buildInputs = [
    chez
    chez-matchable
    chez-mit
    chez-scmutils
    chez-srfi
  ];

  shellHook = ''
  '';
}
