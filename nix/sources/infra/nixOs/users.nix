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
      users = mkOption {
        type = types.attrsOf types.attrs;
        description = "Basic and constant nixOS configuration for the cluster nodes";
        default = {
          users = {
            mutableUsers = false;
            root = { authorizedKeys.keys = cluster.accounts; };
            inherit
              (builtins.mapAttrs (userName: node: cfg.common)
                cluster.account.admins)
              ;
          };
        };
      };
    };
  };
  config = {
    infra.nixOs.nodes =
      builtins.mapAttrs (nodeName: node: cfg.common) cluster.nodes;
  };
}
