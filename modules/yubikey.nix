{ lib, config, pkgs, ... }:

# https://nixos.wiki/wiki/Yubikey

# ykman piv change-pin
# ykman piv change-puk
#
# ykman piv change-management-key --generate --protect
#
#

{
  environment.systemPackages = with pkgs; [
    gnupg
    libu2f-host
    opensc
    pcsctools
    yubico-piv-tool
    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    yubikey-personalization-gui
    yubioath-desktop
  ];

  services.udev.packages = with pkgs; [
    libu2f-host
    yubikey-personalization
  ];
  services.pcscd.enable = true;

  programs = {
    ssh = {
      #startAgent = false;
      agentPKCS11Whitelist = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      extraConfig = ''
        PKCS11Provider "${pkgs.opensc}/lib/opensc-pkcs11.so"
      '';
    };
    #gnupg.agent = {
    #  enable = true;
    ##  enableSSHSupport = true;
    #  #pinentryFlavor = "curses";
    #};
  };

  #services.xserver.displayManager.sessionCommands = ''
  #  # https://github.com/NixOS/nixpkgs/commit/5391882ebd781149e213e8817fba6ac3c503740c
  #  gpg-connect-agent /bye
  #  GPG_TTY=$(tty)
  #  export GPG_TTY
  #'';

  #environment.shellInit = ''
  #  export GPG_TTY="$(tty)"
  #  gpg-connect-agent /bye
  #  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  #'';

  users.groups.yubikey.members = [ "seb" ];
}
