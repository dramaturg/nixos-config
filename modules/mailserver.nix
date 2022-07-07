{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config;
in
{
  imports = [
    ./server.nix
    (builtins.fetchGit {
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git";
      rev = "nixos-20.03";
    })
  ];

  mailserver = {
    enable = true;
    useFsLayout = true;

    certificateScheme = 3;
    dkimKeyBits = 2048;
    enableImap = false;
    enableImapSsl = true;
    enableManageSieve = true;

    monitoring = {
      enable = true;
      alertAddress = "sebastian.krohn@gmail.com";
    };

    domains = [ "orakel-1.ds.ag" ];

    loginAccounts = {
      "seb@ds.ag" = {
        # nix-shell -p mkpasswd --run 'mkpasswd -m sha-512 "super secret password"'
        hashedPassword = "$6$.ol9XGMb3bYq$h9IGg.bpyvhijgs3ps2yUNJJHTpk50TEkTrywBt2pu5k/bvtn1N0oSLIjsJyph4wq2o/iLjYvJapItebz7yAO0";
        quota = "10G";

        aliases = [
          "seb@orakel-1.ds.ag"
        ];
      };
      "robots@ds.ag" = {
        hashedPassword = "$6$tQsCkrVWf/AV62ko$hSu9p5H5Z07QXh5qKD1rg.qv8158f/3I7OZ88yQKry7h6X9GqxJNZdob4OOeL.9ZDRyn3WOS9pr9ItMP3vvrx.";
        sendOnly = true;
      };
    };

    extraVirtualAliases = {
      "postmaster@ds.ag" = "seb@ds.ag";
    };
  };
}
