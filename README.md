# NixOS Config

This is my (NixOS)[https://nixos.org/] config. There are many like it but this
one is mine.

#### Use

The repository splits apart hardware configuration, machines roles and various
snippets. The appropriate files are included in the installer-generated
`configuration.nix` like such:

```
{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./hardware/thinkpad_x250.nix
      ./modules/laptop.nix
    ];

  networking.hostName = "woodstock";

[...]
```

####  Credits
- This repo was originally forked from [sboehler/nixos-config](https://github.com/sboehler/nixos-config) and grew from there
- Lots of ideas for the GPD Pocket were inspired by [andirs config](https://github.com/andir/nixos-gpd-pocket), in particular regarding the kernel options.
- The handy qemu overlay comes from [cleverca22](https://github.com/cleverca22/nixos-configs)
- Some handy i3 scripts were found in [xtruders i3 config](https://github.com/xtruder/nix-profiles/blob/master/modules/user/profiles/i3.nix)

