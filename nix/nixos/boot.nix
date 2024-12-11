_: {
  boot = {
    # kernelPackages = pkgs.linuxPackages_hardened;
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    tmp.cleanOnBoot = true;
  };
}
