{
  boot = {
    initrd = {
      network = {
        enable = true;
        ssh = {
          hostECDSAKey = /root/initrd-ssh-key;
          enable = true;
          port = 2222;
          authorizedKeys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8GLPpUtT+PMw7w1RZyQtrGNcCiRz7RZ69Qdd1r+vt9oXAFXgsRFXyyO7ZNp2KRI+K5ONuTopYS979EEzi83A3Ti9ukIm0Qatcc/Vws8ugBi+SepsBTjuVVi5tLTbyCHzQrDe/J26ONsMkWpoXqTZKKhGqwFYQe2/2MNwzuv4q3V0pnIC5pxpC64KcN/tg9gDCEhllGxCrS8y+HGYcwHA1F7B7LHTiSRbDECVxz4NBhqOm39tkNbRG+WUW77AkJjKiU6LENuKcTZDiC13VVua4epBind5BIXuVYzexqNFDfgunJK/GueurZ6sViZwY6gcdln0KiJQwUUAkc7Tigetd"
            "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAoZ9KzkIud1Aih1Ei02zpE7vCIYkCuLvSB9N5qaACQFfbyGKQq6gIdfKHaAB6SBDdf3exPazcsqiseJr+5UYPo3nZr+YwzFTrvlSFla2RtnOY38DhczbeTtr18SVpDI5S470bnrXalRLZWrmS9SrbSIgdmmmzqc/0buog2RE9RaBAW/cba0CQgYPhk4D9DBQvTPFHA0FEAyBhKUCPiv/MJMSULK3DpNKoTYHXm462p6YFg/LbioS5lDnpXK1WFH6adEMTuqfuX7gWrU2VmadBGNjIVngYNx8GEiEwzrOfbPR1D8U/CDmWHyWLZlxYdjOEomm1HSV0Z7Jx1J+4+W+IwQ=="
          ];
        };
      };
    };
  };
}
