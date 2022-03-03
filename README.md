# NixOS Config

This is my [NixOS](https://nixos.org/) config. There are many like it but this
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

#### Notes

##### Build a package manually

```
nix-build -E "with import <nixpkgs> {}; callPackage ./default.nix {}"
```

##### Upgrade

```
nix-channel --list
nix-channel --add https://nixos.org/channels/nixos-20.09 nixos
nix-channel --update
nixos-rebuild boot --upgrade
```

##### Install a NPM package

```
nix-shell -p node2nix
node2nix -i <(echo '["clubhouse-cli"]')
nix-env -f default.nix -iA clubhouse-cli
```

##### Build lxc image

Install generator:
```
nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i
```

Build:
```
nixos-generate -f lxc -c /etc/nixos/configuration-sandnix.nix
nixos-generate -f lxc-metadata -c /etc/nixos/configuration-sandnix.nix

lxc image import $(nixos-generate -f lxc-metadata) $(nixos-generate -f lxc)
```

####  Credits
- This repo was originally forked from [sboehler/nixos-config](https://github.com/sboehler/nixos-config) and grew from there
- Lots of ideas for the GPD Pocket were inspired by [andirs config](https://github.com/andir/nixos-gpd-pocket), in particular regarding the kernel options.
- The handy qemu overlay comes from [cleverca22](https://github.com/cleverca22/nixos-configs)
- Some handy i3 scripts were found in [xtruders i3 config](https://github.com/xtruder/nix-profiles/blob/master/modules/user/profiles/i3.nix)
- PIA config by [illegalprime](https://github.com/illegalprime/nix/blob/1eb90ceaa9af14eba9d10d1178076e428994de0d/nixos/pia-system.nix)
- Random snippets from [Bob van der Linden](https://github.com/bobvanderlinden/nixos-config/)
- Random snippets from [KiaraGrouwstra](https://github.com/KiaraGrouwstra/nix-config)

