
{ pkgs, lib, config, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ../modules/server.nix
  ];

  environment.systemPackages = with pkgs; [
  ];

  system.autoUpgrade.enable = lib.mkForce false;
  users.mutableUsers = false;

  boot = {
    cleanTmpDir = true;
    loader.grub.device = "/dev/sda";
  };

  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
}
