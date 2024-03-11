{
  lib,
  config,
  pkgs,
  inputs,
  system,
  ...
}: let
  inherit (lib) mkIf mkOption types mdDoc mkMerge;
  cfg = config.app.operations.deploy;
in {
  # options = {
  #   jardin.app.operations.deploy = {
  #     dns = {
  #       iacService = mkOption {
  #         type = types.attrsOf types.any;
  #         description = mdDoc "The dns iac service to use";
  #         default = jardin.infra.octodns;
  #       };
  #     };
  #   };
  # };
  config = {
    infra = {
      disko.enable = true;
      octodns.enable = true;
    };
    flake = {
      jardin = {
        infra = {
          octodns = {
            enable = true;
            # TODO:  use domain to fill this
            records = ["node1.nofreedisk.space" "node2.nofreedisk.space"];
            provider = "cloudflare";
          };
        };
      };
    };
  };
}
