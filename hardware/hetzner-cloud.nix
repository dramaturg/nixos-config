
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
    growPartition = true;
    cleanTmpDir = true;
    loader.grub.device = "/dev/sda";
    loader.timeout = 0;
    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sd_mod" "sr_mod" ];
  };

  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; autoResize = true; };
}
