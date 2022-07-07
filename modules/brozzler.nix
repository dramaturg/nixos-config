{ pkgs, lib, config, configName, ... }:
let
  i3-winmenu = pkgs.stdenv.mkDerivation {
    name = "i3-winmenu";
    buildInputs = [
      (pkgs.python36.withPackages (pythonPackages: with pythonPackages; [
        i3-py
      ]))
    ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp ${../scripts/i3-winmenu.py} $out/bin/i3-winmenu
      chmod +x $out/bin/i3-winmenu
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    # python
    python3Full python3Packages.virtualenv
    (pkgs.python37.withPackages (pythonPackages: with pythonPackages; [
      flask
      ipython
      jupyter
      pandas
      matplotlib
    ]))

  ];

  services.rethinkdb.enable = true;

}