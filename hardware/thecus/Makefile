
result/iso/nixos.iso: default.nix iso.nix
	nix-build -A config.system.build.isoImage \
		-I nixos-config=./iso.nix \
		--argstr system i686-linux ~/nixpkgs/nixos/default.nix

