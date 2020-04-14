
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
# cryptsetup luksOpen /dev/sda2 root-pv

# pvcreate /dev/mapper/root-pv 
# vgcreate root-vg /dev/mapper/root-pv
# lvcreate -L 4G -n swap root-vg
# lvcreate -l 90%FREE -n root root-vg

# mkswap /dev/mapper/root--vg-swap
# swapon /dev/mapper/root--vg-swap

# mkfs.vfat -n BOOT /dev/sda1
# mkfs.btrfs -L root /dev/mapper/root--vg-root
# mount /dev/mapper/root--vg-root /mnt

# mkdir /mnt/boot
# mount /dev/sda1 /mnt/boot
```

## Connect to Wifi

```
wpa_passphrase ESSID > /etc/wpa_suuplicant.conf
systemctl restart wpa_supplicant
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

