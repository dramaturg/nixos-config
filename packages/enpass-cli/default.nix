{ stdenv, pkgs, lib, buildGoModule, fetchFromGitHub }:

#with import <nixos>{};

buildGoModule rec {
  pname = "enpass-cli";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "hazcod";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-u2n+xyrVT1vUJBl83tiz99scdBgyTCUbeZkSK5Jbfk8=";
  };

  vendorSha256 = null;

  ldflags = [ "-s" "-w" "-X main.version=${version}" "-X main.commit=${src.rev}" ];

  # we need to rename the resulting binary but can't use buildFlags with -o here
  # because these are passed to "go install" which does not recognize -o
  postBuild = ''
    mv $GOPATH/bin/cli $GOPATH/bin/exo

    mkdir -p manpage
    $GOPATH/bin/docs --man-page
    rm $GOPATH/bin/docs

    $GOPATH/bin/completion bash
    $GOPATH/bin/completion zsh
    rm $GOPATH/bin/completion
  '';

  meta = {
    description = "A commandline utility for the Enpass password manager.";
    homepage = "https://github.com/hazcod/enpass-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dramaturg ];
    mainProgram = "enp";
  };
}

