
all:

# nix-build '<nixpkgs/nixos>' -I nixos-config=./raspberrypi1-image.nix -A config.system.build.sdImage

sd-image-raspberrypi3.iso:
	ln -snf "$(shell ./raspberrypi3-image.nix)" "$@"

# make result-uboot-OrangePiZeroPlus2H5/u-boot-sunxi-with-spl.bin
result-uboot-%/u-boot-sunxi-with-spl.bin:
	nix-build -o $(@D) -E 'let plat = ((import <nixpkgs> ){}).pkgsCross.aarch64-multiplatform; in plat.uboot$*'

result-uboot-armv7l-BeagleboneBlack/u-boot.img:
	nix-build -o $(@D) -E 'let plat = ((import <nixpkgs> ){}).pkgsCross.armv7l-hf-multiplatform; in plat.ubootBeagleboneBlack'

result-uboot-armv7l-%/u-boot-sunxi-with-spl.bin:
	nix-build -o $(@D) -E 'let plat = ((import <nixpkgs> ){}).pkgsCross.armv7l-hf-multiplatform; in plat.uboot$*'

# make result-ubootdefconfig-arm7l-orangepi_pc/u-boot-sunxi-with-spl.bin
result-ubootdefconfig-arm7l-%/u-boot-sunxi-with-spl.bin:
	nix-build -o $(@D) -E 'let plat = ((import <nixpkgs> ){}).pkgsCross.armv7l-hf-multiplatform; in plat.buildUBoot{defconfig = "$*_defconfig"; extraMeta.platforms = ["armv7l-linux"]; filesToInstall = ["u-boot-sunxi-with-spl.bin"];}'

