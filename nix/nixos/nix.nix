_: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      system-features = [
        "benchmark"
        "big-parallel"
        "nixos-test"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "012:15";
      options = "-d";
    };
  };
  boot = {
    # kernelPackages = pkgs.linuxPackages_hardened;
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    tmp.cleanOnBoot = true;
  };
}
