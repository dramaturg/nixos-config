{ pkgs, lib, config, ... }:

{
  imports = [
    ./hardware/thinkpad_x250.nix
    ./modules/embeddeddev.nix
    ./modules/mobiledev.nix
    ./modules/wireguard.nix
    ./modules/laptop.nix
  ];

  environment.systemPackages = with pkgs; [
    steam
    calibre
  ];

  services.xserver = {
    displayManager.lightdm.autoLogin = {
      enable = true;
      user = "seb";
    };
  };

  services.restic.backups = {
    remotebackup = {
      paths = [
        "/etc/nixos"
        "/home/seb/code"
        "/home/seb/logs"
      ];
      repository = "s3:ams3.digitaloceanspaces.com/restic-seb";
      passwordFile = "/etc/nixos/secrets/restic_s3_pass";
      s3CredentialsFile = "/etc/nixos/secrets/restic_s3_space";
      timerConfig = {
        OnCalendar = "21:15";
      };
      initialize = true;
    };
  };
}
