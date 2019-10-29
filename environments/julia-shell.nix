{ pkgs ? import <nixpkgs> {}}:

let
fhs = pkgs.buildFHSUserEnv {
  name = "julia-fhs";
  targetPkgs = pkgs: with pkgs;
    [
      git
      gitRepo
      gnupg
      autoconf
      curl
      procps
      gnumake
      utillinux
      m4
      gperf
      unzip
      cudatoolkit
      linuxPackages.nvidia_x11
      libGLU_combined
      xorg.libXi xorg.libXmu freeglut
      xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib
      ncurses5
      stdenv.cc
      binutils

      julia_11
      atom
      arpack

      # IJulia.jl
      mbedtls
      zeromq3
      # ImageMagick.jl
      imagemagickBig
      # HDF5.jl
      hdf5
      # Cairo.jl
      cairo
      gettext
      pango.out
      glib.out
      # Gtk.jl
      gtk3
      gdk_pixbuf
      # GZip.jl # Required by DataFrames.jl
      gzip
      zlib
      # GR.jl # Runs even without Xrender and Xext, but cannot save files, so those are required
      xorg.libXt
      xorg.libX11
      xorg.libXrender
      xorg.libXext
      glfw
      freetype
    ];
  multiPkgs = pkgs: with pkgs; [ zlib ];
  runScript = "bash";
  profile = ''
    export CUDA_PATH=${pkgs.cudatoolkit}
    # export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib
    export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
    export EXTRA_CCFLAGS="-I/usr/include"
    '';
  };

in pkgs.stdenv.mkDerivation {
  name = "julia-shell";
  nativeBuildInputs = [fhs];
  shellHook = "exec julia-fhs";
}
