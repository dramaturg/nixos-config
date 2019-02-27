{
  boot = {
    initrd = {
      network = {
        enable = true;
        ssh = {
          hostECDSAKey = /root/initrd-ssh-key;
          enable = true;
          port = 2222;
          authorizedKeys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8GLPpUtT+PMw7w1RZyQtrGNcCiRz7RZ69Qdd1r+vt9oXAFXgsRFXyyO7ZNp2KRI+K5ONuTopYS979EEzi83A3Ti9ukIm0Qatcc/Vws8ugBi+SepsBTjuVVi5tLTbyCHzQrDe/J26ONsMkWpoXqTZKKhGqwFYQe2/2MNwzuv4q3V0pnIC5pxpC64KcN/tg9gDCEhllGxCrS8y+HGYcwHA1F7B7LHTiSRbDECVxz4NBhqOm39tkNbRG+WUW77AkJjKiU6LENuKcTZDiC13VVua4epBind5BIXuVYzexqNFDfgunJK/GueurZ6sViZwY6gcdln0KiJQwUUAkc7Tigetd"];
        };
      };
    };
  };
}
