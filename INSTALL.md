
# Installing NixOS

## Partitioning 

```
# gdisk /dev/sda

[...]

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048         1026047   500.0 MiB   EF00  EFI System
   2         1026048       500118158   238.0 GiB   8E00  Linux LVM

[...]

# cryptsetup luksFormat /dev/sda2
# cryptsetup luksOpen /dev/sda2

# pvcreate /dev/mapper/root-pv 
# vgcreate root-vg /dev/mapper/root-pv /dev/mapper/root-pv 
# lvcreate -L 4G -n swap root-vg
# lvcreate -l 90% -n root root-vg

# mkfs.vfat -n BOOT /dev/sda1
# mkfs.btrfs -L root /dev/mapper/root--vg-root

# mount /dev/mapper/root--vg-root /mnt
# swapon /dev/mapper/root--vg-swap 
# mkdir /mnt/boot
# mount /dev/sda1 /mnt/boot
```

## Installing

```
# nixos-generate-config --root /mnt
```

`/mnt/etc/nixos/configuration.nix` for luks:

```
{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
	  ./thinkpad.nix
    ];

  boot.loader.grub.efiSupport = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/sda2";
      preLVM = true;
    }
  ];

  networking.hostName = "woodstock";

  system.stateVersion = "18.09";
}
```

Start the installation:
```
# nixos-install
```

