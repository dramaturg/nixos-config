{ config, pkgs, lib, ... }:
#  let
#    unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/2428f5dda13475afba2dee93f4beb2bd97086930.tar.gz;
#  in
{
  imports = [
    ./networking.nix
    ./resolved.nix
    ./efi.nix
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];

  nixpkgs = {
    config = {
#      packageOverrides = pkgs: {
#        unstable = import unstableTarball {
#          config = config.nixpkgs.config;
#        };
#      };
      allowUnfree = true;
    };
  };

  nix.buildCores = lib.mkDefault 0;
  nix.autoOptimiseStore = true;
  #nix.nixPath = [
  #  "/nix"
  #  "nixos-config=/etc/nixos/configuration.nix"
  #];
  nix.gc.automatic = true;
  nix.gc.dates = "Thu 03:15";
  nix.gc.options = "--delete-older-than 14d";

  time.timeZone = "Europe/Berlin";

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  hardware = {
    enableAllFirmware = true;
    enableKSM = true;
    cpu = {
      amd.updateMicrocode = true;
      intel.updateMicrocode = true;
    };
  };
  # zramSwap.enable = true;
  boot.cleanTmpDir = true;
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  environment.systemPackages = with pkgs; [
    # shell
    ack
    lftp
    screen tmux

    # system, hardware & fs
    exfat gptfdisk hdparm nvme-cli
    lsof
    patchelf
    pciutils usbutils
    psmisc
    smartmontools
    sysstat
    upower
    lshw
    acpi lm_sensors
    #cryptsetup
    ltrace strace linuxPackages.perf

    # base tools
    file
    git
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
  '';

  programs = {
    gnupg = {
      agent = {
        enable = true;
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        custom = "${./zsh-custom}";
        theme = "silvio";
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
          "helm"
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

        eval $(${pkgs.coreutils}/bin/dircolors "${./dircolors.ansi-universal}")

        if [ $USER = "seb" ]; then
          systemctl --user import-environment
        fi
      '';
    };
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
        '';
    };
  };

  virtualisation.docker.enable = true;

  services.btrfs = {
    autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
    };
  };

  services.openssh = {
    enable = true;
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
        ];
      };
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8GLPpUtT+PMw7w1RZyQtrGNcCiRz7RZ69Qdd1r+vt9oXAFXgsRFXyyO7ZNp2KRI+K5ONuTopYS979EEzi83A3Ti9ukIm0Qatcc/Vws8ugBi+SepsBTjuVVi5tLTbyCHzQrDe/J26ONsMkWpoXqTZKKhGqwFYQe2/2MNwzuv4q3V0pnIC5pxpC64KcN/tg9gDCEhllGxCrS8y+HGYcwHA1F7B7LHTiSRbDECVxz4NBhqOm39tkNbRG+WUW77AkJjKiU6LENuKcTZDiC13VVua4epBind5BIXuVYzexqNFDfgunJK/GueurZ6sViZwY6gcdln0KiJQwUUAkc7Tigetd"
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAoZ9KzkIud1Aih1Ei02zpE7vCIYkCuLvSB9N5qaACQFfbyGKQq6gIdfKHaAB6SBDdf3exPazcsqiseJr+5UYPo3nZr+YwzFTrvlSFla2RtnOY38DhczbeTtr18SVpDI5S470bnrXalRLZWrmS9SrbSIgdmmmzqc/0buog2RE9RaBAW/cba0CQgYPhk4D9DBQvTPFHA0FEAyBhKUCPiv/MJMSULK3DpNKoTYHXm462p6YFg/LbioS5lDnpXK1WFH6adEMTuqfuX7gWrU2VmadBGNjIVngYNx8GEiEwzrOfbPR1D8U/CDmWHyWLZlxYdjOEomm1HSV0Z7Jx1J+4+W+IwQ=="
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
}
