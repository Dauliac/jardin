{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mdDoc types;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
  inherit (config.infra) nixOs;
  inherit (config.domain) cluster;
in {
  imports = [
    ./commons.nix
    ./node.nix
    ./users.nix
    ./kubernetes.nix
  ];
  options.perSystem =
    mkPerSystemOption
    ({
      config,
      pkgs,
      ...
    }: let
      cfg = config.infra.nixOs;
    in {
      options = {
        infra.nixOs = {
          mkNixOs = mkOption {
            description = mdDoc "NixOs node manifest";
            default = {
              domain,
              nodes,
              admins,
            }: let
              nixifiedNodes =
                builtins.mapAttrs
                (nodeName: node: (
                  cfg.commons {inherit domain;}
                  // (cfg.mkUserConfig admins)
                  // (cfg.mkNodeConfig {inherit nodeName node;})
                ))
                nodes;
              kubernetesNodes = cfg.kubernetes.mkNixOs {
                nodes = nixifiedNodes;
              };
            in
              nixifiedNodes // kubernetesNodes;
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
    });
}
