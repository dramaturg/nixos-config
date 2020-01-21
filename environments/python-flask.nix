with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "python-environment";

  buildInputs = with pkgs; [
    (python3Full.withPackages (ps: with ps; [
      flask
    ]))
    pypi2nix
  ];

  shellHook = ''
    export FLASK_DEBUG=1
    export FLASK_APP="main.py"
  '';
}
