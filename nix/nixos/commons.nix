{
  config,
  lib,
  jardinLib,
  ...
}: {
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        system-features = [
          "benchmark"
          "big-parallel"
          "nixos-test"
        ];
        optimise.automatic = true;
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
    # virtualisation = {
    #   podman = {
    #     enable = true;
    #     defaultNetwork.settings.dns_enabled = true;
    #   };
    #   oci-containers.backend = "podman";
    #   libvirtd.enable = true;
    # };
    security.polkit.enable = true;
    networking.useDHCP = true;
    networking.hostName = jardinLib.currentNodeHostname config.jardin.nodes;
    networking.firewall.enable = true;
}
