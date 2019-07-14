
# https://nixos.org/nixops/manual/#idm140737322418000
# https://github.com/NixOS/nixops/blob/master/nix/hetzner-bootstrap.nix
#
# nixops create -d winter deployments/winter.nix
# nixops info -d winter
# nixops deploy -d winter
# nixops modify -d winter deployments/winter.nix

{
  network = {
    enableRollback = true;
    description = "winter at hetzner";
  };
  defaults = {
    documentation.enable = false;
  };
  winter = {
    imports = [ ../winter.nix ];
      deployment.targetEnv = "hetzner";
      deployment.hetzner.createSubAccount = false;
      deployment.hetzner.robotUser = builtins.readFile ../secrets/hetzner-user-winter;
      deployment.hetzner.robotPass = builtins.readFile ../secrets/hetzner-pass-winter;

      deployment.hetzner.mainIPv4 = "136.243.5.88";
      deployment.hetzner.partitions = ''
        zerombr
        clearpart --all --initlabel --drives=sda,sdb,sdc,sdd

        part raid.11 --size=500 --ondrive=sda
        part raid.12 --size=12000 --grow --ondrive=sda
        part raid.21 --size=500 --ondrive=sdb
        part raid.22 --size=12000 --grow --ondrive=sdb
        part raid.31 --size=500 --ondrive=sdc
        part raid.32 --size=12000 --grow --ondrive=sdc
        part raid.41 --size=500 --ondrive=sdd
        part raid.42 --size=12000 --grow --ondrive=sdd

        raid /boot --fstype ext4 --label boot --device md1 --level=1 raid.11 raid.21 raid.31 raid.41
        raid pv.01 --device md0 --level=5 raid.12 raid.22 raid.32 raid.42

        volgroup vg00 pv.01

        logvol / --label root --vgname=vg00 --fstype=ext4 --size=20000 --name=lv_root
        logvol swap --vgname=vg00 --name=lv_swap --grow --size=1024 --maxsize=4096
        logvol /home --label home --vgname=vg00 --fstype=ext4 --size=10000 --name=lv_home
        logvol /s --label share --vgname=vg00 --fstype=ext4 --size=100000 --percent=90 --name=lv_share
      '';
  };
}