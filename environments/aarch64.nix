let pkgs = import <nixpkgs> {
  crossSystem = {
    config = "aarch64-unknown-linux-gnu";
  };
};
in
  pkgs.callPackage (
    {mkShell, pkg-config, zlib}:
    mkShell {
      nativeBuildInputs = [ pkg-config ]; # you build dependencies here
      buildInputs = [ zlib ]; # your dependencies here
    }
  ) {}