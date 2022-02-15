with import <nixpkgs> {};

#{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "3.0.3";
  name = "shen-cl-${version}";
  isExecutable = true;

  src = fetchFromGitHub {
    owner = "Shen-Language";
    repo = "shen-cl";
    rev = "v${version}";
    sha256 = "0rcwkqww5wbijlpnr3jdnd9r95nm7dbvk0vsgl3iylgi5sdhdls1";
  };

  nativeBuildInputs = [ libffi git ];
  buildInputs = [ clisp ccl ecl sbcl ];

  #preConfigure = ''
  #  cmakeFlags="-DCMAKE_BUILD_TYPE=Release"
  #'';


  ## Thsese are the original flags from the helm makefile
  #buildFlagsArray = ''
  #  -ldflags=-X k8s.io/helm/pkg/version.Version=v${version}
  #  -w
  #  -s
  #'';

  preBuild = ''
    make precompile
  '';

  #postInstall = ''
  #  mkdir -p $bin/share/bash-completion/completions
  #  mkdir -p $bin/share/zsh/site-functions
  #  $bin/bin/helm completion bash > $bin/share/bash-completion/completions/helm
  #  $bin/bin/helm completion zsh > $bin/share/zsh/site-functions/_helm
  #'';

  meta = with stdenv.lib; {
    homepage = http://www.shenlanguage.org/;
    description = "Shen is a portable functional programming language by Mark Tarver. It is the successor to the award-winning Qi language, with the added goal of being highly portable across platforms.";
    license = licenses.bsd3;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}
