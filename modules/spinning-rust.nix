{ pkgs, lib, config, ... }:

{

  # build kernel with BFQ scheduler support
  boot.kernelPatches =  [ {
    name = "enable_bfq";
    patch = null;
    extraConfig = ''
      IOSCHED_BFQ y
    '';
  } ];

  # set the i/o scheduler on spinning rust
  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
}
