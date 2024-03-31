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
              nodes,
              admins,
            }: let
              kubeNixOs = cfg.kubernetes.mkNixOs {inherit nodes;};
            in
              builtins.mapAttrs
              (nodeName: node: (
                cfg.common
                // (cfg.mkUserConfig admins)
                // (cfg.mkNodeConfig {inherit nodeName node;})
                // kubeNixOs.${nodeName}
              ))
              nodes;
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
