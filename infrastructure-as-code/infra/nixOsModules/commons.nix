{
  config,
  lib,
  jardinLib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.jardin;
in
  mkIf cfg.enable
  {
    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
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
    };
    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      oci-containers.backend = "podman";
      libvirtd.enable = true;
    };
    environment.defaultPackages = lib.mkForce [];
    # NOTE: required by libvirtd
    security.polkit.enable = true;
    networking.useDHCP = true;
    networking.hostName = jardinLib.currentNodeHostname config.jardin.nodes;
    networking.firewall.enable = true;
  }
