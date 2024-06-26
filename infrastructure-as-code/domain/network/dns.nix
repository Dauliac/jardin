{
  lib,
  config,
  ...
}: let
  inherit (config.domain) cluster;
  inherit (lib) mkOption types mdDoc;
  cfg = config.domain.cluster.networks.dns;
in {
  options = {
    domain = {
      cluster = {
        networks = {
          dns = {
            mkRecords = mkOption {
              description = mdDoc "Create DNS records for the cluster.";
              default = {
                domain,
                nodes,
              }:
                builtins.mapAttrs
                (hostname: node: {
                  key = "${hostname}.${domain}";
                  inherit (node) ip;
                })
                nodes;
            };
            nameServerKind = mkOption {
              type = types.enum ["privacyFriendly" "privacyLess"];
              default = "privacyFriendly";
              description = mdDoc "The kind of name server to use.";
            };
            domain = mkOption {
              example = "example.com";
              description = mdDoc "The domain to create DNS records for.";
              type = cluster.types.digitalStorageUnit;
            };
            records = mkOption {
              description = mdDoc "Dns records of the cluster";
              # TODO: expand it to list to have more dns records per nodes in the future
              type = types.attrsOf (types.submodule (_: {
                options = {
                  key = mkOption {
                    description =
                      mdDoc "The address ip use as record value for dns";
                    type = types.singleLineStr;
                  };
                  ip = mkOption {
                    description = mdDoc "The ip address of the dns record";
                    type = types.singleLineStr;
                  };
                  kind = mkOption {
                    description =
                      mdDoc "The address ip use as record value for dns";
                    type = types.enum ["A" "CNAME"];
                    default = "A";
                  };
                  ttl = mkOption {
                    type = types.int;
                    description = mdDoc "The TTL for the DNS records.";
                    default = 3600;
                  };
                };
              }));
            };
          };
        };
      };
    };
  };
  config = {
    domain.cluster.networks.dns = {
      inherit (cluster) domain;
      records = cfg.mkRecords {
        inherit (cluster) domain;
        inherit (cluster) nodes;
      };
    };
  };
}
