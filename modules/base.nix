{ config, pkgs, lib, ... }:
let
  configName = lib.mkDefault "default";
  ssh-moduli-file = pkgs.runCommand "ssh-moduli-file" {} ''
    awk '$5 >= 2048' ${pkgs.openssh}/etc/ssh/moduli > $out
  '';
  optimize-nix = pkgs.writeScriptBin "optimize-nix" ''
    #!${pkgs.bash}/bin/bash

    set -eu

    # Delete everything from this profile that isn't currently needed
    nix-env --delete-generations old

    # Delete generations older than a week
    nix-collect-garbage
    nix-collect-garbage --delete-older-than 7d

    # Optimize
    nix-store --gc --print-dead
    nix-store --optimise

    nixos-rebuild boot
  '';
in
{
  imports = [
    ./networking.nix
    ./vim.nix
    #../secrets/sops
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      sqlite.interactive = true;
    };
  };
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  nix = {
    buildCores = lib.mkDefault 0;
    autoOptimiseStore = true;
    useSandbox = true;
    trustedUsers = [ "@wheel" ];

    gc.automatic = true;
    gc.dates = "Thu 03:15";
    gc.options = "--delete-older-than 7d";

    optimise.automatic = true;

    extraOptions = ''
      auto-optimise-store = true
      binary-caches-parallel-connections = 10
      min-free = ${toString (1024 * 1024 * 1024 * 3)}
      max-free = ${toString (1024 * 1024 * 1024 * 6)}
    '';

    #nixPath =
    #  options.nix.nixPath.default ++
    #  [ "nixpkgs-overlays=/etc/nixos/overlays/" ];
  };
  system.autoUpgrade.enable = lib.mkDefault true;

  time.timeZone = lib.mkDefault "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  #console.keyMap = "us";

  # zramSwap.enable = true;
  boot.cleanTmpDir = lib.mkDefault false;
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576;
    "net.ipv4.tcp_congestion_control" = "bbr";
    # see https://news.ycombinator.com/item?id=14814530
    "net.core.default_qdisc" = "fq";
  };

  environment.systemPackages = with pkgs; [
    # shell
    lftp
    screen
    tmux
    rlwrap
    any-nix-shell

    # system, hardware & fs
    exfat
    gptfdisk
    hdparm
    smartmontools
    lsof
    patchelf
    pciutils
    usbutils
    psmisc
    lshw
    acpi
    lm_sensors
    mcron

    # base tools
    file
    (if config.services.xserver.enable then gitAndTools.gitFull else git)
    parallel
    moreutils
    patchutils
    gnumake

    # net
    ethtool
    wget
    curl
    rclone
    rsync
    mtr
    tcpdump
    iptables
    inetutils

    # nix
    nix-prefetch-scripts
    nix-prefetch-github
    (pkgs.writeShellScriptBin "nixFlakes" ''
      exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
    optimize-nix
  ];

  environment.interactiveShellInit = ''
    # A nix query helper function
    nq()
    {
      case "$@" in
        -h|--help|"")
          printf "nq: A tiny nix-env wrapper to search for packages in package name, attribute name and description fields\n";
          printf "\nUsage: nq <case insensitive regexp>\n";
          return;;
      esac
      nix-env -qaP --description \* | grep -i "$@"
    }

    export TERM=xterm-256color

    export HISTCONTROL=ignoredups:erasedups
    export HISTSIZE=300000
    export HISTFILESIZE=200000
  '';

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        theme = "gianu";
        plugins = [
          "aws"
          "docker"
          "git-extras"
          "git-flow"
          "gitfast"
          "history-substring-search"
          "kubectl"
          "mosh"
          "python"
          "rsync"
          "sudo"
          "systemd"
          "tmux"
        ];
      };
      interactiveShellInit = ''
        export EDITOR=vim
        export PATH=$HOME/.local/bin:$PATH
        export PASSWORD_STORE_X_SELECTION=primary
        export GPG_TTY=$(tty)
        HYPHEN_INSENSITIVE="true"

        setopt autocd extendedglob
        setopt share_history
        setopt hist_ignore_dups

        eval $(${pkgs.coreutils}/bin/dircolors "${./dircolors.ansi-universal}")

        if [ $USER = "seb" ]; then
          systemctl --user import-environment
        fi


        typeset -U path cdpath fpath

        setopt auto_cd
        cdpath=($HOME /mnt)

        zstyle ':completion:*' group-name \'\'
        zstyle ':completion:*:descriptions' format %d
        zstyle ':completion:*:descriptions' format %B%d%b
        zstyle ':completion:*:complete:(cd|pushd):*' tag-order \
               'local-directories named-directories'
      '';
      shellInit = ''
        #disable config wizard
        zsh-newuser-install() { :; }
      '';
      shellAliases = {
        nix-search        = "nix-env -qaP";
        nix-list          = "nix-env -qaP \"*\" --description";
        dkr               = "docker run -ti --rm";
        repo_root         = "git rev-parse --show-toplevel";
        rr                = "cd $(repo_root)";
        myip              = "dig -4 +short @resolver1.opendns.com myip.opendns.com A ; dig -6 +short @resolver1.opendns.com myip.opendns.com AAAA";
        myip4             = "dig -4 +short @resolver1.opendns.com myip.opendns.com A";
        myip6             = "dig -6 +short @resolver1.opendns.com myip.opendns.com AAAA";
      };
      promptInit = ''
        any-nix-shell zsh --info-right | source /dev/stdin
      '';
    };
    ssh = {
      startAgent = lib.mkDefault true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
    tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "a";
      terminal = "screen-256color";
      extraConfig = ''
        bind-key = set-window-option synchronize-panes\; display-message "synchronize-panes is now #{?pane_synchronized,on,off}"
      '';
    };
    iotop.enable = true;
    command-not-found.enable = false;
  };

  services.openssh = {
    enable = lib.mkDefault true;
    useDns = lib.mkDefault false;
    passwordAuthentication = lib.mkDefault false;

    forwardX11 = lib.mkDefault false;

    allowSFTP = lib.mkDefault true;
    sftpFlags = lib.mkDefault [ "-f AUTHPRIV" "-l INFO" ];
    moduliFile = ssh-moduli-file;
    #logLevel = lib.mkDefault "INFO";

    # https://infosec.mozilla.org/guidelines/openssh
    kexAlgorithms = [
      "curve25519-sha256@libssh.org"
      "ecdh-sha2-nistp521"
      "ecdh-sha2-nistp384"
      "ecdh-sha2-nistp256"
      "diffie-hellman-group-exchange-sha256"
    ];
    ciphers = [
      "chacha20-poly1305@openssh.com"
      "aes256-gcm@openssh.com"
      "aes256-ctr"
    ];
    macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "hmac-sha2-512"
      "hmac-sha2-256"
    ];
    extraConfig = ''
      ClientAliveInterval 30
      ClientAliveCountMax 3

      AllowGroups root wheel users ssh

      LoginGraceTime 30
      MaxAuthTries 5
    '';
  };
  programs.mosh.enable = config.services.openssh.enable;

  services.fstrim.enable = true;

  services.timesyncd.enable = lib.mkDefault true;

  nix.sshServe = {
    enable = lib.mkDefault true;
    keys = config.users.extraUsers.seb.openssh.authorizedKeys.keys;
    protocol = "ssh-ng";
  };

  users = {
    defaultUserShell = pkgs.zsh;
    extraUsers = {
      seb = {
        home = "/home/seb";
        description = "Seb";
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "dialout" ]
          ++ (lib.optional config.networking.networkmanager.enable "networkmanager")
          ++ (lib.optional config.hardware.sane.enable "lp")
          ++ (lib.optional config.hardware.sane.enable "scanner")
          ++ (lib.optional config.virtualisation.docker.enable "docker")
          ++ (lib.optional config.virtualisation.libvirtd.enable "libvirtd")
          ++ (lib.optional config.virtualisation.lxd.enable "lxd")
          ++ (lib.optional config.virtualisation.virtualbox.host.enable "vboxusers");
        uid = 1000;
        openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
          lib.strings.removeSuffix "\n" (
            builtins.readFile ../dotfiles/ssh_authorized_keys.pub));
      };
      root = {
        openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
          lib.strings.removeSuffix "\n" (
            builtins.readFile ../dotfiles/ssh_authorized_keys.pub));
      };
    };
  };

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  services.journald.extraConfig = ''
    SystemMaxUse=128M
    MaxRetentionSec=7day
  '';
}
