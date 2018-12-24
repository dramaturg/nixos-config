# NixOS Config

This was originally forked from [sboehler/nixos-config](https://github.com/sboehler/nixos-config). Other parts and pieces were slapped on afterwards mostly to replicate the base of my i3 desktop setup on NixOS.

#### Use

Hardware-specific files are located in the top-level directory:

- pocket.nix: GPD Pocket Laptop
- thinkpad.nix: Thinkpad X250

These are then included in installer-generated `configuration.nix` like such:

```
{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./pocket.nix
    ];

  networking.hostName = "zwerg";

  system.stateVersion = "18.09";
}
```

####  Credits
- [sboehler/nixos-config](https://github.com/sboehler/nixos-config)
- Lots of ideas for the GPD Pocket were inspired by [this repository](https://github.com/andir/nixos-gpd-pocket), in particular regarding the kernel options.
- Instead of using channels directly the nixpkgs repository is checked out as /nix/nixpkgs (usually tracking stable). [This article](https://matrix.ai/2017/03/13/intro-to-nix-channels-and-reproducible-nixos-environment/) was very helpful when I set everything up.
