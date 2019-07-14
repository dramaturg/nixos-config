{ pkgs, lib, config, ... }:

let
  configName = "pocket";
in
{
  imports =
    [
      ./hardware/gpd_pocket.nix
      ./modules/embeddeddev.nix
      ./modules/laptop.nix
    ];

  i3statusConfigFile = "i3status-gpd-pocket";
}
