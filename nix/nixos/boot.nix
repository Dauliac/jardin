_: {
  boot = {
    plymouth.enable = true;
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    tmp.cleanOnBoot = true;
  };
}
