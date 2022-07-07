{ config, options, lib, modulesPath, pkgs, system ? "i686-linux", ... }:

let
  # https://nixos.wiki/wiki/Snippets#Adding_compiler_flags_to_a_package
  optimizeWithFlags = pkg: flags:
    pkgs.lib.overrideDerivation pkg (old:
    let
      newcflags = pkgs.lib.foldl' (acc: x: "${acc} ${x}") "" flags;
      oldcflags = if (pkgs.lib.hasAttr "NIX_CFLAGS_COMPILE" old)
        then "${old.NIX_CFLAGS_COMPILE}"
        else "";
      oldcxxflags = if (pkgs.lib.hasAttr "NIX_CXXFLAGS_COMPILE" old)
        then "${old.NIX_CXXFLAGS_COMPILE}"
        else "";
    in
    {
      NIX_CFLAGS_COMPILE = "${oldcflags} ${newcflags}";
      NIX_CXXFLAGS_COMPILE = "${oldcxxflags} ${newcflags}";
    });
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
      #"-finline-functions"
    ];

  useGeodeOptimizations = stdenv: stdenv //
    { mkDerivation = args: stdenv.mkDerivation (args // {
        NIX_CFLAGS_COMPILE = toString (args.NIX_CFLAGS_COMPILE or "") +
          " -march=geode -mtune=geode -O3 -fno-align-jumps -fno-align-functions" +
          " -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer";
        NIX_CXXFLAGS_COMPILE = toString (args.NIX_CXXFLAGS_COMPILE or "") +
          " -march=geode -mtune=geode -O3 -fno-align-jumps -fno-align-functions" +
          " -fno-align-labels -fno-align-loops -pipe -fomit-frame-pointer";
        #stdenv = overrideCC stdenv gcc6;
        #stdenv = pkgs.pkgsMusl.stdenv;
      });
    };

  stdenv = useGeodeOptimizations;
#  pkgs = import <nixpkgs> {
#	   #crossOverlays = [
#    overlays = [
#      (self: super: {
#        stdenv = super.stdenvAdapters.impureUseNativeOptimizations super.stdenv;
#      })
#    ];
#  };
in
{
  imports = [
    ../../modules/server.nix
    ../../modules/lowram.nix
    <nixpkgs/nixos/modules/profiles/minimal.nix>
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  networking.hostName = "trash";

  nixpkgs = {
	  config.packageOverrides = pkgs: {
        nix = optimizeForGeode pkgs.nix;
        boost = optimizeForGeode pkgs.boost;
      };
	  overlays = [
      (self: super: {
        linux = pkgs.linuxPackagesFor (pkgs.linux.override {
          structuredExtraConfig = with lib.kernel; {
            X86_32 = yes;
            SMP = no;
            MGEODE_LX = yes;
            NR_CPUS = 1;
            NOHIGHMEM = yes;

            FB_GEODE = yes;
            FB_GEODE_LX = yes;
            CRYPTO_DEV_GEODE = yes;
            SCx200 = yes;
            SCx200HR_TIMER = yes;
			GEODE_WDT = yes;
			MFD_CS5535 = yes;

            BPF_JIT = yes;
            BPF_STREAM_PARSER = yes;

            AGP = no;
            DRM = no;
            BT = no;
            NUMA = no;
            XEN = no;
            SND = no;
            RAPIDIO = no;
            DECNET = no;
            YENTA = no;
            ATALK = no;
            "6LOWPAN" = no;
            IEEE802154 = no;
            HAMRADIO = no;
            CAN = no;
            WIMAX = no;
            NFC = no;
            ALTERA_STAPL = no;
            VMWARE_VMCI = no;
            FCOE = no;
            FUSION = no;
            FIREWIRE = no;
            ARCNET = no;
            ATM_DRIVERS = no;
            PLIP = no;
            SLIP = no;
            B43 = no;
            B44 = no;
            USB_VIDEO_CLASS = no;
            VIDEO_PVRUSB2 = no;
            DVB_USB = no;
            VIDEO_EM28XX = no;
            INFINIBAND = no;
            EDAC = no;
            FB_TFT = no;
            SPEAKUP = no;
            MOST = no;
            GREYBUS = no;
            STM = no;
            INTEL_TH = no;
            FPGA = no;
            REISERFS_FS = no;
            JFS_FS = no;
            OCFS2_FS = no;
          };
          ignoreConfigErrors = true;
        });
      })
    ];
  };

  environment.noXlibs = lib.mkForce false;
  security.polkit.enable = lib.mkForce false;
  documentation.doc.enable = lib.mkForce false;
  
  boot = {
    kernelParams = [
      "clocksource=scx200_hrt" # geode-specific clocksource
      "noexec=off" # disable NX - it's not available on Geode
	  "lxfb.mode_option=800x600@75" # geode lx framebuffer

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
