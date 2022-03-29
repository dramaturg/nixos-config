{ config, options, lib, modulesPath, pkgs, system ? "i686-linux", ... }:

let
  optimizeWithFlags = pkg: flags:
    pkgs.lib.overrideDerivation pkg (old:
    let
      newflags = pkgs.lib.foldl' (acc: x: "${acc} ${x}") "" flags;
      oldflags = if (pkgs.lib.hasAttr "NIX_CFLAGS_COMPILE" old)
        then "${old.NIX_CFLAGS_COMPILE}"
        else "";
    in
    {
      NIX_CFLAGS_COMPILE = "${oldflags} ${newflags}";
    });
  useGeodeOptimizations = stdenv: stdenv //
    { mkDerivation = args: stdenv.mkDerivation (args // {
        NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or "") +
          " -march=geode -mtune=geode -O3 -fno-align-jumps -fno-align-functions" +
          " -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer";
        #stdenv = overrideCC stdenv gcc6;
      });
    };
  optimizeForGeode = pkg:
    optimizeWithFlags pkg [
      "-march=geode"
      "-mtune=geode"
      "-O3"
      "-fno-align-jumps"
      "-fno-align-functions"
      "-fno-align-labels"
      "-fno-align-loops"
      "-pipe"
      "-fomit-frame-pointer"
    ];
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    nix = optimizeForGeode pkgs.nix;
    boost = optimizeForGeode pkgs.boost;
  };

  zramSwap.enable = true;
  security.polkit.enable = lib.mkForce false;

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
        SCx200 y
        SCx200HR_TIMER y

        NOHIGHMEM y

        BT n
        YENTA n
        RAPIDIO n
        DECNET n
        ATALK n
        6LOWPAN n
        IEEE802154 n
        HAMRADIO n
        CAN n
        WIMAX n
        NFC n
        ALTERA_STAPL n
        VMWARE_VMCI n
        FCOE n
        FUSION n
        FIREWIRE n
        ARCNET n
        ATM_DRIVERS n
        PLIP n
        SLIP n
        B43 n
        B44 n
        USB_VIDEO_CLASS n
        VIDEO_PVRUSB2 n
        DVB_USB n
        VIDEO_EM28XX n
        INFINIBAND n
        EDAC n
        FB_TFT n
        SPEAKUP n
        MOST n
        GREYBUS n
        STM n
        INTEL_TH n
        FPGA n
        REISERFS_FS n
        JFS_FS n
        OCFS2_FS n

        AGP n
        DRM n
        SND n

        BPF_JIT y
        BPF_STREAM_PARSER y
      '';
    #}
    #{
    #  name = "geode_nopl_emu";
    #  patch = ./geode_nopl_emu.patch;
    } ];

    kernelParams = [
      #"clocksource=scx200_hrt" # geode-specific clocksource
      "noexec=off" # disable NX - it's not available on Geode

      # https://linuxreviews.org/HOWTO_make_Linux_run_blazing_fast_(again)_on_Intel_CPUs
      # https://make-linux-fast-again.com/
      # we run some very old hardware here ...
      "mitigations=off"
    ];

    initrd = {
      kernelModules = [
        "libata"
        "pata_amd"
        "pata_cs5536"
        "pata_acpi"
        "ata_generic"
        "cs5535_mfd"
        "sata_sil"
        "e1000"
        "dm_raid"
        "geode_rng"
      ];
      availableKernelModules = [
        "ohci_pci"
        "ehci_pci"
        "usbhid"
        "usb_storage"
      ];
    };
  };
}
