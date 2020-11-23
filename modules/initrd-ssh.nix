{ config, pkgs, lib, ... }:

# mkdir -p /etc/secrets/initrd/
# chmod 750 /etc/secrets/initrd/
# ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
# ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key

{
  boot.initrd = {
    supportedFilesystems = [ "zfs" ];
    network = {
      enable = true;

      ssh = {
        enable = true;
        port = lib.mkDefault 2222;
        hostKeys = [
          "/etc/secrets/initrd/ssh_host_rsa_key"
          "/etc/secrets/initrd/ssh_host_ed25519_key"
        ];
	authorizedKeys = with lib; concatLists (mapAttrsToList (name: user: if elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else []) config.users.users);
      };
      postCommands = ''
        echo 'cryptsetup-askpass' >> /root/.profile
      '';
    };
  };

}
