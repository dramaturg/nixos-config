{ pkgs, lib, config, ... }:
#let
#  external-mac = "c8:60:00:54:b0:90";
#  ext-if = "e0";
#  external-ip = "136.243.5.88";
#  external-gw = "136.243.5.65";
#  external-ip6 = "2a01:4f8:211:1ed7::2";
#  external-gw6 = "fe80::1";
#  external-netmask = 26;
#  external-netmask6 = 64;
#in
{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    <nixpkgs/nixos/modules/profiles/hardened.nix>
    <nixpkgs/nixos/modules/profiles/headless.nix>
    <nixpkgs/nixos/modules/profiles/minimal.nix>

    ./modules/server.nix
  ];

  security.allowUserNamespaces = true;
  security.allowSimultaneousMultithreading = true;

  nix.useSandbox = true;

  nix.buildCores = 0; # 0 is auto detection


  programs.mosh.enable = true;
  programs.mtr.enable = true;
}