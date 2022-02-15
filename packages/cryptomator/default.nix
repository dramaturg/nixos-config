{ pkgs, stdenv, writeScript, gtk3, appimageTools }:

#
# https://www.reddit.com/r/NixOS/comments/f98mou/buildfhsuserenvappimage_recipe_for_gtk_programs/
#

let
  inherit (appimageTools) extractType2 wrapType2;

  name = "cryptomator";
  src = pkgs.fetchurl {
    url = "https://dl.bintray.com/cryptomator/cryptomator/1.4.15/cryptomator-1.4.15-x86_64.AppImage";
    sha256 = "0iy02g8jcvc4xbii70h78xqk8h8dj53h7rv8d0mpwwh7phd0allx";
  };

  # you can add more paths as required
  xdg_dirs = builtins.concatStringsSep ":" [
    "${gtk3}/share/gsettings-schemas/${gtk3.name}"
  ];

  # not necessary, here for debugging purposes
  # adapted from the original runScript of appimageTools
  extracted_source = extractType2 { inherit name src; };
  debugScript = writeScript "run" ''
    #!${stdenv.shell}

    export APPDIR=${extracted_source}
    export APPIMAGE_SILENT_INSTALL=1

    # >>> inspect the script running environment here <<<
    echo "INSPECT: ''${GIO_EXTRA_MODULES:-no extra modules!}"
    echo "INSPECT: ''${GSETTINGS_SCHEMA_DIR:-no schemas!}"
    echo "INSPECT: ''${XDG_DATA_DIRS:-no data dirs!}"

    cd $APPDIR
    exec ./AppRun "$@"
  '';
in wrapType2 {
  inherit name src;

  # for debugging purposes only
  #runScript = debugScript;

  extraPkgs = pkgs: with pkgs; [
    # put runtime dependencies if any here
  ];

  # the magic happens here
  # other potential variables of interest:
  #   GIO_EXTRA_MODULES, GSETTINGS_SCHEMA_DIR
  profile = ''
    export XDG_DATA_DIRS="${xdg_dirs}''${XDG_DATA_DIRS:+:"''$XDG_DATA_DIRS"}"
  '';
}