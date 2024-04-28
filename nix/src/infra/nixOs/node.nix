{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption mdDoc;
  cfg = config.infra.nixOs;
  inherit (config.domain) cluster;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in {
  options.perSystem =
    mkPerSystemOption
    (_: {
      options = {
        infra.nixOs = {
          mkNodeConfig = mkOption {
            description =
              mdDoc "Function to generate general node specific configuration";
            default = {
              nodeName,
              node,
            }: {
              # TODO: if we enhance the node configuration, we need to develop nixOs module;
              jardin.node = node;
              networking = {hostName = nodeName;};
            };
          };
          nodePart = mkOption {
            description = mdDoc "Function to generate node specific configuration";
            default =
              builtins.mapAttrs
              (nodeName: node: (cfg.commons // cfg.mkNodeConfig {inherit nodeName node;}))
              cluster.nodes;
          };
        };
      };
    });
}
