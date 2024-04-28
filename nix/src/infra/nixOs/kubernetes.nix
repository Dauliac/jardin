{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption mdDoc;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in {
  options.perSystem =
    mkPerSystemOption
    ({
      config,
      pkgs,
      ...
    }: let
      cfg = config.infra.nixOs.kubernetes;
    in {
      options = {
        infra.nixOs.kubernetes = {
          mkMasterConfig = mkOption {
            description =
              mdDoc "Function to generate kubernetes master specific configuration";
            default = {master}: {
              # NOTE: Here an example to get api-token
              # We maybe need to use jardin to get the token
              #  https://github.com/NixOS/nixpkgs/blob/18ff53d7656636aa440b2f73d2da788b785e6a9c/nixos/tests/kubernetes/rbac.nix#L118
              # NOTE: This allow to do not depends from external DNS server
              # TODO: build extraHosts from domain.cluster.networks.dns for all nodes
              networking.extraHosts = "${master.jardin.node.ip} ${master.networking.hostName}";
              environment.systemPackages = with pkgs; [
                kubectl
                kubernetes
              ];
              services.kubernetes = {
                roles = ["master" "node"];
                masterAddress = master.networking.hostName;
                apiserverAddress =
                  if master.jardin.domain == null
                  then "https://${master.networking.hostName}:${cfg.apiServerPort}"
                  else "https://${master.jardin.domain}:${cfg.apiServerPort}";
                /*
                master.api.uri;
                */
                easyCerts = true;
                apiserver = {
                  securePort = master.api.port;
                  advertiseAddress = master.jardin.node.ip;
                };
                addons.dns.enable = true;

                # NOTE: needed if you use swap
                # TODO: manage kubelets into vms without swap for system hardening
                kubelet.extraOpts = "--fail-swap-on=false";
              };
            };
          };
          mkNodeConfig = mkOption {
            description =
              mdDoc "Function to generate kubernetes node specific configuration";
            default = {
              node,
              master,
            }: {
              # NOTE: This allow to do not depends from external DNS server
              # TODO: build extraHosts from domain.cluster.networks.dns for all nodes
              networking.extraHosts = "${master.ip} ${master.networking.hostName}";
              environment.systemPackages = with pkgs; [
                kubectl
                kubernetes
              ];

              services.kubernetes = {
                roles = ["node"];
                masterAddress = "${master.networking.hostName}";
                # FIXME: this is not working for multi master cluster:
                # as said here https://logs.nix.samueldr.com/nixos-kubernetes/2019-09-05
                easyCerts = true;
                # NOTE: point kubelet and other services to kube-apiserver
                kubelet.kubeconfig.server = master.api.uri;
                apiserverAddress = master.api.uri;
                addons.dns.enable = true;
                # NOTE: needed if you use swap
                # TODO: manage kubelets into vms without swap for system hardening
                kubelet.extraOpts = "--fail-swap-on=false";
              };
            };
          };
          apiServerPort = mkOption {
            type = lib.types.int;
            default = 6443;
            description = "Port for kube-apiserver";
          };
          mkNixOs = mkOption {
            description =
              mdDoc "Function to generate nixos configuration for kubernetes";
            default = {nodes}: let
              # TODO: jardin should use different dichotomy to deploy master and nodes to avoid this kind of conflicts
              mastersInstances = lib.attrValues (lib.filterAttrs (nodeName: node: node.jardin.node.role == "master") nodes);
            in
              builtins.mapAttrs
              (
                nodeName: node:
                  if node.jardin.node.role == "master"
                  then
                    cfg.mkMasterConfig
                    {
                      master = node;
                    }
                  else
                    cfg.mkMasterConfig
                    {
                      inherit node;
                      # TODO: improve this code to support multi master cluster
                      master = lib.head mastersInstances;
                    }
              )
              nodes;
          };
        };
      };
    });
}
