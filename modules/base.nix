{ config, pkgs, lib, ... }:
  let
    configName = lib.mkDefault "default";
  in
{
  imports = [
    ./networking.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  nixpkgs = {
    config = {
#      packageOverrides = super: let self = super.pkgs; in {
#        fftw = super.fftw.override {
#          configureFlags =
#            [ "--enable-shared" "--disable-static"
#              "--enable-threads" "--disable-doc"
#            ]
#        };
#      };
      allowUnfree = true;
      sqlite.interactive = true;
      vim.ruby = false;
    };
  };

  nix = {
    buildCores = lib.mkDefault 0;
    autoOptimiseStore = true;
    gc.automatic = true;
    gc.dates = "Thu 03:15";
    gc.options = "--delete-older-than 14d";

    extraOptions = ''
      binary-caches-parallel-connections = 10
      min-free = ${toString (1024*1024*1024*3)}
      max-free = ${toString (1024*1024*1024*6)}
    '';
  };

  time.timeZone = "Europe/Berlin";

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # zramSwap.enable = true;
  boot.cleanTmpDir = false;
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
    screen tmux
    rlwrap
    any-nix-shell

    # system, hardware & fs
    exfat gptfdisk hdparm nvme-cli
    lsof
    patchelf
    pciutils usbutils
    psmisc
    sysstat
    lshw
    acpi lm_sensors
    ltrace strace linuxPackages.perf
    mcron

    # base tools
    file
    (if config.services.xserver.enable then gitAndTools.gitFull else git)
    gnupg
    vim
    stow
    parallel
    moreutils
    patchutils
    p7zip zip
    gnumake

    # net
    wget curl rclone rsync
    mtr
    tcpdump
    iptables
    inetutils
    magic-wormhole

    # nix
    nix-prefetch-scripts
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
  '';

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
          "rsync"
          "stack"
          "history-substring-search"
          "aws"
          "cargo"
          "docker"
          "docker-compose"
          "docker-machine"
          "git"
          "git-flow"
          "golang"
          "kubectl"
          "nomad"
          "mosh"
          "perl"
          "python"
          "rust"
          "sudo"
          "systemd"
          "terraform"
          "vagrant"
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
        wergwerf_firefox  = "firefox --new-instance --profile $(mktemp -d)";
        wergwerf_chromium = "chromium --user-data-dir $(mktemp -d)";
      };
      promptInit = ''
        any-nix-shell zsh --info-right | source /dev/stdin
      '';
    };
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
    tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "`";
      terminal = "screen-256color";
    };
  };

  environment.etc."gitconfig".source = ../dotfiles/gitconfig;

  services.openssh = {
    enable = lib.mkDefault true;
    useDns = lib.mkDefault false;
    passwordAuthentication = false;
  };

  services.fstrim.enable = true;

  services.timesyncd.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    extraUsers = {
      seb = {
        home = "/home/seb";
        description = "Seb";
        isNormalUser = true;
        extraGroups = ["wheel" "docker" "libvirtd" "audio" "networkmanager"];
        uid = 1000;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8GLPpUtT+PMw7w1RZyQtrGNcCiRz7RZ69Qdd1r+vt9oXAFXgsRFXyyO7ZNp2KRI+K5ONuTopYS979EEzi83A3Ti9ukIm0Qatcc/Vws8ugBi+SepsBTjuVVi5tLTbyCHzQrDe/J26ONsMkWpoXqTZKKhGqwFYQe2/2MNwzuv4q3V0pnIC5pxpC64KcN/tg9gDCEhllGxCrS8y+HGYcwHA1F7B7LHTiSRbDECVxz4NBhqOm39tkNbRG+WUW77AkJjKiU6LENuKcTZDiC13VVua4epBind5BIXuVYzexqNFDfgunJK/GueurZ6sViZwY6gcdln0KiJQwUUAkc7Tigetd"
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAoZ9KzkIud1Aih1Ei02zpE7vCIYkCuLvSB9N5qaACQFfbyGKQq6gIdfKHaAB6SBDdf3exPazcsqiseJr+5UYPo3nZr+YwzFTrvlSFla2RtnOY38DhczbeTtr18SVpDI5S470bnrXalRLZWrmS9SrbSIgdmmmzqc/0buog2RE9RaBAW/cba0CQgYPhk4D9DBQvTPFHA0FEAyBhKUCPiv/MJMSULK3DpNKoTYHXm462p6YFg/LbioS5lDnpXK1WFH6adEMTuqfuX7gWrU2VmadBGNjIVngYNx8GEiEwzrOfbPR1D8U/CDmWHyWLZlxYdjOEomm1HSV0Z7Jx1J+4+W+IwQ=="
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKrPAfq2dGmsqr9aqT3vvObJCE/Q4TAz23CREfxu5eZDvUMfGz+xNWy6+9dNjthjmisLuSN73YH5vPsrm9ibluVUkbbo5VltA8/ok8QaCas1yS9s6gnn9bU210fW0j5vVr/IQugkC3pJVwc2bOhBPlh1Rrq1kGPi41bhIihEgA4VLiXGGT4xclkxm0qICllA1/EpNBXTFLnML3w2zHxO+catGJVpKg7ptuwM0m8x91CQVAvzt6V6yRl3aDKEt1ecGXB8xj/KVrcgCnbdWZsf8YR315gmyXEMSZUVPWsimKoLSFZ7kYwWCGu4PwOPckpqeKeENKtkaFnoCd36A/j0j+C0ONr3sNPYuUfiV1EfDyUeVjT8J5QX+tjaFkBn9vifikTf8pUZSz1mH0dvmCikRLfQRjZkv7vwclUINvDYJ0Ths6AmcP1Sz7+YmlbVEniJlxB4q7hTsVIAXmKpChUlkuPOJCzNr5JGjgMNQigerLm3IaAC/f/cR0uJBvf83MPxS2iuL1UTuBgHyl4noOnCKPwG9uBQ6U/KXEeMUOAEftAM5aICUTP8tKFys9/JyJNRYvUGOrz2l0LSyObYa4cPwWEM7U+dXB08VA8gY8lfYZYTSwMjbCgOgdKNhcpYklYnDx23s/68ZeweQ/zoF5UbO3T9ZuMZSGfi4cmJgvZJrd5w=="
        ];
      };
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8GLPpUtT+PMw7w1RZyQtrGNcCiRz7RZ69Qdd1r+vt9oXAFXgsRFXyyO7ZNp2KRI+K5ONuTopYS979EEzi83A3Ti9ukIm0Qatcc/Vws8ugBi+SepsBTjuVVi5tLTbyCHzQrDe/J26ONsMkWpoXqTZKKhGqwFYQe2/2MNwzuv4q3V0pnIC5pxpC64KcN/tg9gDCEhllGxCrS8y+HGYcwHA1F7B7LHTiSRbDECVxz4NBhqOm39tkNbRG+WUW77AkJjKiU6LENuKcTZDiC13VVua4epBind5BIXuVYzexqNFDfgunJK/GueurZ6sViZwY6gcdln0KiJQwUUAkc7Tigetd"
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAoZ9KzkIud1Aih1Ei02zpE7vCIYkCuLvSB9N5qaACQFfbyGKQq6gIdfKHaAB6SBDdf3exPazcsqiseJr+5UYPo3nZr+YwzFTrvlSFla2RtnOY38DhczbeTtr18SVpDI5S470bnrXalRLZWrmS9SrbSIgdmmmzqc/0buog2RE9RaBAW/cba0CQgYPhk4D9DBQvTPFHA0FEAyBhKUCPiv/MJMSULK3DpNKoTYHXm462p6YFg/LbioS5lDnpXK1WFH6adEMTuqfuX7gWrU2VmadBGNjIVngYNx8GEiEwzrOfbPR1D8U/CDmWHyWLZlxYdjOEomm1HSV0Z7Jx1J+4+W+IwQ=="
	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKrPAfq2dGmsqr9aqT3vvObJCE/Q4TAz23CREfxu5eZDvUMfGz+xNWy6+9dNjthjmisLuSN73YH5vPsrm9ibluVUkbbo5VltA8/ok8QaCas1yS9s6gnn9bU210fW0j5vVr/IQugkC3pJVwc2bOhBPlh1Rrq1kGPi41bhIihEgA4VLiXGGT4xclkxm0qICllA1/EpNBXTFLnML3w2zHxO+catGJVpKg7ptuwM0m8x91CQVAvzt6V6yRl3aDKEt1ecGXB8xj/KVrcgCnbdWZsf8YR315gmyXEMSZUVPWsimKoLSFZ7kYwWCGu4PwOPckpqeKeENKtkaFnoCd36A/j0j+C0ONr3sNPYuUfiV1EfDyUeVjT8J5QX+tjaFkBn9vifikTf8pUZSz1mH0dvmCikRLfQRjZkv7vwclUINvDYJ0Ths6AmcP1Sz7+YmlbVEniJlxB4q7hTsVIAXmKpChUlkuPOJCzNr5JGjgMNQigerLm3IaAC/f/cR0uJBvf83MPxS2iuL1UTuBgHyl4noOnCKPwG9uBQ6U/KXEeMUOAEftAM5aICUTP8tKFys9/JyJNRYvUGOrz2l0LSyObYa4cPwWEM7U+dXB08VA8gY8lfYZYTSwMjbCgOgdKNhcpYklYnDx23s/68ZeweQ/zoF5UbO3T9ZuMZSGfi4cmJgvZJrd5w=="
        ];
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
    MaxRetentionSec=3day
  '';
}
