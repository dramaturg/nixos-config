let
  overlay = import ./overlay.nix;
in { pkgs ? import <nixpkgs> { overlays = [overlay]; } }:

pkgs.mkShell {
  
}
