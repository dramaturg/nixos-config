{
  zramSwap.enable = true;

  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 500;
    "vm.swappiness" = 100;
    "vm.dirty_background_ratio" = 1;
    "vm.dirty_ratio" = 50;
  };
}
