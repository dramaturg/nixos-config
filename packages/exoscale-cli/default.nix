{ stdenv, buildGo114Package, fetchFromGitHub }:

buildGo114Package {
  pname = "exoscale-cli";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner  = "exoscale";
    repo   = "cli";
    rev    = "dcd5469b7cd6c8b6ea1825926381af445b90fdf1";
    sha256 = "06ibs8c71gj4nniraz4kp98nnc6d1sh860j5j3v9drwzy21807l3";
  };

  goPackagePath = "github.com/exoscale/cli";
  subPackages = [ "." ];
  goDeps = ./deps.nix;

  # can't use buildFlags here because these are passed to "go install"
  # which does not recognize -o
  postBuild = ''
    mv go/bin/cli go/bin/exo
  '';

  meta = {
    description = "Command-line tool for everything at Exoscale: compute, storage, dns";
    homepage    = https://github.com/exoscale/cli;
    license     = stdenv.lib.licenses.asl20;
    maintainers = [ "Sebastian Krohn <sebastian.krohn@exoscale.ch>" ];
  };
}
