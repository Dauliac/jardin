# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib
, config
, ...
}:
let
  inherit (lib) mkOption mdDoc types;
  cfg = config.infra.nixOs;
  inherit (config.domain) cluster;
in
{
  imports = [ ./commons.nix ./node.nix ./users.nix ];
  options = {
    infra.nixOs = {
      mkNixOs = mkOption {
        description = mdDoc "NixOs node manifest";
        default =
          { nodes
          , admins
          ,
          }: (builtins.mapAttrs
            (nodeName: node: (
              cfg.common
              // (cfg.mkUserConfig admins)
              // (cfg.mkNodeConfig { inherit nodeName node; })
            ))
            nodes);
      };
      nodes = mkOption {
        description = mdDoc "NixOs nodes manifests";
        type = types.attrs;
        default = cfg.mkNixOs {
          inherit (cluster) nodes;
          inherit (cluster.account) admins;
        };
      };
    };
  };
}
