with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "intel-graphics-compiler";
  version = "2019-01-15";
  isLibrary = true;
  isExecutable = false;
  
  src = fetchFromGitHub {
    owner = "intel";
    repo = "intel-graphics-compiler";
    rev = "64632faa3cdad142b809f63274a5ce1f315489d6";
    sha256 = "081w9dhsgbjn477jdl1pj2qrnb19dgbbj6g0bv1353960n156mzv";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    git
    flex
    bison
    gcc
    llvmPackages.clang-unwrapped
    llvmPackages.llvm
    zlib
  ];

  preConfigure = ''
    git clone -b release_40 https://github.com/llvm-mirror/clang clang_source
    git clone https://github.com/intel/opencl-clang common_clang
    git clone https://github.com/intel/llvm-patches llvm_patches
    git clone -b release_40 https://github.com/llvm-mirror/llvm llvm_source
    git clone -b release_70 https://github.com/llvm-mirror/llvm llvm7.0.0_source

    cmakeFlags="-DIGC_OPTION__OUTPUT_DIR=$out -DCMAKE_BUILD_TYPE=Release"
  '';

  meta = {
    description = "The Intel(R) Graphics Compiler for OpenCL(TM) is an llvm based compiler for OpenCL(TM) targeting Intel Gen graphics hardware architecture";
    homepage = https://github.com/intel/intel-graphics-compiler;
    license = stdenv.lib.licenses.mit;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}
