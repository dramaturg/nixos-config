{ config, options, lib, modulesPath, system ? "i686-linux", ... }:

{
  imports =
  [ 
    ./default.nix
    ../iso.nix
  ];

  isoImage.makeEfiBootable = false;
}
