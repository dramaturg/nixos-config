with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "go-environment";

  buildInputs = [
    go_1_13
    golint
    gocode
    gotags
    glide
    dep
    dep2nix
    go2nix
    vgo2nix
    gotools
    go-protobuf
  ];

  shellHook = ''
    export GOPATH=$HOME/go
  '';
}
