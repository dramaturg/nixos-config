let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  buildInputs = with pkgs; [
    (python38.withPackages(ps: with ps; [
      pip
    ]))
    #pypi2nix
  ];
  shellHook = ''
    export PIP_PREFIX="$(pwd)/_build/pip_packages"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.8/site-packages:$PYTHONPATH"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH

    pip install setuptools
    echo pip install -r requirements.txt
    echo pip install --install-option="--prefix=$PIP_PREFIX" -e .
  '';
}
