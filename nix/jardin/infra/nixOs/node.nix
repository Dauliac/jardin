{ config
, lib
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
      mkNodeConfig = mkOption {
        description =
          mdDoc "Function to generate general node specific configuration";
        default =
          { nodeName
          , node
          ,
          }: {
            networking = { hostName = nodeName; };
          };
      };
    };
  };
  config = {
    infra.nixOs.nodes =
      builtins.mapAttrs
        (nodeName: node: (cfg.mkNodeConfig { inherit nodeName node; }))
        cluster.nodes;
  };
}
