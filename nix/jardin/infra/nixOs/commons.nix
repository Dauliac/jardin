{ lib
, config
, pkgs
, inputs
, system
, ...
}:
let
  inherit (lib) mkOption mdDoc types mkIf;
  cfg = config.infra.nixOs;
  inherit (config) infra;
  inherit (config.domain) cluster;
in
{
  options = {
    infra.nixOs = {
      common = mkOption {
        type = types.attrsOf types.attrs;
        description = "Basic and constant nixOS configuration for the cluster nodes";
        default = {
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
          };
          boot = { kernelPackages = [ pkgs.linuxPackages_hardened ]; };
          # nixpkgs = { overlays = [ self.overlays.pkgs ]; };
          defaultNetwork.settings.dns_enabled = true;
          zramSwap.enable = true;
          virtualisation = {
            podman = {
              enable = true;
              defaultNetwork.settings.dns_enabled = true;
            };
            oci-containers.backend = "podman";
          };
          services.openssh.enable = true;
          # users.users.root.openssh.authorizedKeys.keys = authorized-keys;
          networking.useDHCP = true;
          networking.firewall.enable = true;
        };
      };
    };
  };
  config = {
    infra.nixOs.nodes =
      builtins.mapAttrs (nodeName: node: cfg.common) cluster.nodes;
  };
}
