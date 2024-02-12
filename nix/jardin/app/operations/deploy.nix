{ lib
, config
, pkgs
, inputs
, system
, ...
}:
let
  inherit (lib) mkIf mkOption types mdDoc mkMerge;
  cluster = config.flake.nixCluster;
  inherit (config.flake.lib) jardin;
  cfg = jardin.app.operations.deploy;
in
{
  options = {
    jardin.app.operations.deploy = {
      dns = {
        iacService = mkOption {
          type = types.attrsOf types.any;
          description = mdDoc "The dns iac service to use";
          default = jardin.infra.octodns;
        };
      };
    };
  };
  config = {
    flake = {
      jardin = {
        infra = {
          octodns = {
            enable = true;
            # TODO:  use domain to fill this
            records = [ "node1.nofreedisk.space" "node2.nofreedisk.space" ];
            provider = "cloudflare";
          };
        };
      };
      lib = mkMerge [
        {
          deploy = {
            # mkTasks = { pkgs }: { dns = jardin.infra.octodns.task; };
          };
        }
      ];
      # perSystem = { pkgs, ... }: {
      #   apps.jardin-tasks-deploy = jardin.deploy.mkTasks { inherit pkgs; };
      # };
    };
    # }];
  };
}
