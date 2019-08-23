
{ config, options, lib, modulesPath, system ? "i686-linux" }:

{
  imports =
  [ 
    ./default.nix
    ../iso.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  isoImage.makeEfiBootable = false;
}
