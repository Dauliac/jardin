{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption mdDoc types;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in {
  options.perSystem =
    mkPerSystemOption
    (_: {
      options = {
        infra.nixOs = {
          commons = mkOption {
            description = mdDoc "Basic and constant nixOS configuration for the cluster nodes";
            # type = types.attrs;
            default = {domain}: {
              jardin = {
                inherit domain;
              };
              nix.settings = {
                experimental-features = ["nix-command" "flakes"];
                auto-optimise-store = true;
                gc = {
                  automatic = true;
                  persistent = true;
                  dates = "012:15";
                  options = "-d";
                };
              };
              # TODO: change it into perSystem option
              # boot = { kernelPackages = pkgs.linuxPackages_hardened; };
              virtualisation = {
                podman = {
                  enable = true;
                  defaultNetwork.settings.dns_enabled = true;
                };
                oci-containers.backend = "podman";
                libvirtd.enable = true;
              };
              # required by libvirtd
              security.polkit.enable = true;
              services.openssh.enable = true;
              networking.useDHCP = true;
              networking.firewall.enable = true;
            };
          };
        };
      };
    });
}
