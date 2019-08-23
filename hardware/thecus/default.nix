{ config, options, lib, modulesPath, pkgs, system ? "i686-linux" }:

{
  imports = [
    ./geode.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot = {
    kernelPatches =  [ {
      name = "thecus";
      patch = null;
      extraConfig = ''
        X86_32 y
        SMP n
        MGEODE_LX y
        NR_CPUS 1

        FB_GEODE y
        FB_GEODE_LX y
        CRYPTO_DEV_GEODE y
      '';
    } ];

    # https://make-linux-fast-again.com/
    # we run some very old hardware here ...
    kernelParams = [
      "noibrs"
      "noibpb"
      "nopti"
      "nospectre_v2"
      "nospectre_v1"
      "l1tf=off"
      "nospec_store_bypass_disable"
      "no_stf_barrier"
      "mds=off"
      "mitigations=off"
    ];
  };
}
