with import <nixpkgs> {};

let
  zippey = pkgs.fetchgit {
          url = "https://bitbucket.org/sippey/zippey.git";
          rev = "f037ce9e9b968fa053f95cd2804a248021ffcb41";
          sha256 = "1w2xp0qbpijbmq7qd99iiazvnm8sm1ip43lcxqss5w71a3aw4lch";
          };
in pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
    ]))
  ];

  ZIPPEY = "${zippey}/zippey.py";

  shellHook = ''
	  export PATH="${zippey}:$PATH"
  '';
}
