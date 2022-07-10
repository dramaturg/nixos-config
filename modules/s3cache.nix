# https://www.tweag.io/blog/2019-11-21-untrusted-ci/
# https://nixos.wiki/wiki/Binary_Cache
# nix-store --generate-binary-cache-key binarycache.example.com cache-priv-key.pem cache-pub-key.pem

{ config, pkgs, lib, ... }:

let
  nix-cache-info = pkgs.writeTextFile "nix-cache-info" ''
    StoreDir: /nix/store
    WantMassQuery: 1
    Priority: 30
  '';
  upload-to-s3 = pkgs.writeScriptBin "nix-upload-to-s3" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p bash


    set -eu
    set -f # disable globbing
    export IFS=' '

    set -x

    [[ "$OUT_PATHS" == *[0-9] ]] && true || exit 0

    #    case $OUT_PATHS in
    #      *-environment)
    #        exit 0
    #      ;;
    #      *-[a-z][a-z][a-z])
    #        exit 0
    #      ;;
    #      *.drv)
    #        exit 0
    #      ;;
    #      *.service)
    #        exit 0
    #      ;;
    #      *-system-units)
    #        exit 0
    #      ;;
    #      *.iso)
    #        exit 0
    #      ;;
    #    esac
    
    export AWS_SHARED_CREDENTIALS_FILE=/etc/nixos/secrets/s3cache-credentials

    echo "Signing and uploading paths" $OUT_PATHS
    exec nix copy --to 's3://?region=nl-ams&endpoint=nix-cache-dsa3.s3.nl-ams.scw.cloud&secret-key=/etc/nixos/secrets/s3cache-secret.key' $OUT_PATHS
  '';
in
{
  nix = {
    settings = {
      substituters = [ "https://nix-cache-dsa3.s3-website.nl-ams.scw.cloud/" ];
      trusted-public-keys = [
        "nix-cache-dsa3.s3-website.nl-ams.scw.cloud:TO4eXW6vwbQMUzSVDKScYUFlrxSfMaivQ4yeCHLplDQ="
      ];
    };

    extraOptions = ''
      post-build-hook = ${upload-to-s3}/bin/nix-upload-to-s3
    '';
  };
}
