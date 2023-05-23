{ pkgs, lib, config, ... }:
{
  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      IdentityFile /etc/nixos/secrets/nixbuild-ssh-key
  '';
  
  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };
  
  nix = {
    distributedBuilds = true;
    buildMachines = [
      { hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
      { hostName = "eu.nixbuild.net";
        system = "aarch64-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
      { hostName = "eu.nixbuild.net";
        system = "armv7l-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
      { hostName = "eu.nixbuild.net";
        system = "i686-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
    ];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
