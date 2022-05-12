
{ pkgs, ... }:
{
  programs.adb.enable = true;
  users.users.seb.extraGroups = ["adbusers"];

  boot.kernelModules = [ "kvm-amd" ];
  virtualisation.libvirtd.enable = true;

  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
    };
  };

  environment.systemPackages = with pkgs; [
    android-udev-rules
    #android-studio
    #android-file-transfer
    #jmtpfs
    #androidenv.platformTools

    #(myEnvFun {
    #  name = "android90";
    #  buildInputs = [ androidsdk_9_0
    #                  ant
    #                  openjdk
    #                ];
    #})
  ];
}
