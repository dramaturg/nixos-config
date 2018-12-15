{ stdenv, pkgs, fetchurl }:

stdenv.mkDerivation rec {
  name = "snow-generic";
  
  src = fetchurl {
    url = "http://snow.iro.umontreal.ca/?operation=download&pkg=snow-generic/v1.1.2&fakeoutput=/snow-generic-v1.1.2.tgz";
    sha256 = "0nv7wny0czbh2ryyiz01lzjwi1ryx288c4lhjdwl89wcklvlmj3v";
  };
  sourceRoot = "snow-generic/v1.1.2";

  configurePhase = ''
    ./configure --site-root=$out --install-hosts=yes
  '';


  meta = {
    description = "Scheme Now!, also know as Snow, is a repository of Scheme packages that are portable to several popular implementations of Scheme";
    homepage = http://snow.iro.umontreal.ca ;
    license = stdenv.lib.licenses.lgpl21;
    maintainers = [ "Sebastian Krohn <seb@ds.ag>" ];
  };
}