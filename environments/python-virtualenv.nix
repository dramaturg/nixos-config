let
  pkgs = import <nixpkgs> {};
  #nanomsg-py = .... build expression for this python library;
in pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
      pip
      pathlib2
      pafy
      spotipy
      mutagen
      beautifulsoup4
      unicode-slugify
      titlecase
      logzero
      pyyaml
      appdirs
    ]))
    pypi2nix
    #nanomsg-py
  ];
  shellHook = ''
    alias pip3="PIP_PREFIX='$(pwd)/_build/pip_packages' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.7/site-packages:$PYTHONPATH"
    unset SOURCE_DATE_EPOCH
  '';
}