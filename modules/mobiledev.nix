
{ pkgs, ... }:
{
  programs.adb.enable = true;
  users.users.seb.extraGroups = ["adbusers"];

  environment.systemPackages = with pkgs; [
    gambit

    android-udev-rules
    android-studio
    android-file-transfer
    jmtpfs

    (myEnvFun {
      name = "android43";
      buildInputs = [ androidenv.androidsdk_4_3
                      ant
                      openjdk
                    ];
    })
  ];
}