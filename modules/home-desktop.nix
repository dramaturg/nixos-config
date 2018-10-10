{ pkgs, lib, config, ... }:
{
  imports = [
    ./home.nix
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };
}

