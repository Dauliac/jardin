{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mdDoc;
  cfg = config.infra.nixOs;
  inherit (config.domain) cluster;
in {
  options = {
    infra.nixOs = {
      mkNodeConfig = mkOption {
        description =
          mdDoc "Function to generate general node specific configuration";
        default = {
          nodeName,
          node,
        }: {
          networking = {hostName = nodeName;};
        };
      };
      nodePart = mkOption {
        description = mdDoc "Function to generate node specific configuration";
        default =
          builtins.mapAttrs
          (nodeName: node: (cfg.common // cfg.mkNodeConfig {inherit nodeName node;}))
          cluster.nodes;
      };
    };
  };
}
