# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib, ... }:
let
  inherit (lib) mkOption mdDoc;
in
{
  options = {
    infra.nixOs = {
      common = mkOption {
        # TODO: check if this is still needed
        # type = types.attrsOf types.attrs;
        description = mdDoc "Basic and constant nixOS configuration for the cluster nodes";
        default = {
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
          };
          # TODO: change it into perSystem option
          # boot = { kernelPackages = pkgs.linuxPackages_hardened; };
          virtualisation = {
            podman = {
              enable = true;
              defaultNetwork.settings.dns_enabled = true;
            };
            oci-containers.backend = "podman";
          };
          services.openssh.enable = true;
          networking.useDHCP = true;
          networking.firewall.enable = true;
        };
      };
    };
  };
}
