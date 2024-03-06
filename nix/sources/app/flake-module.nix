{ config
, lib
, flake-parts-lib
, ...
}:
let
  inherit (lib) mkOption types mdDoc;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  # TODO: We maybe should generate this file from rust
  flake = {
    flakeModules = {
      nixCluster = {
        options.nixCluster = {
          cluster = {
            name = mkOption {
              description = mdDoc "The human readable name of your cluster";
              type = types.singleLineStr;
            };
            dns = {
              zone = mkOption {
                description = mdDoc "The root dns zone of your cluster";
                type = types.singleLineStr;
              };
              provider = mkOption {
                description = mdDoc "";
                type = types.enum [ "cloudflare" ];
              };
            };
            nodes = mkSubmoduleOptions {
              default = { };
              description = mdDoc "The nodes of your cluster";
              types = types.attrsOf {
                role = mkOption {
                  description = mdDoc "The role of the node";
                  type = types.enum [ "node" ];
                };
                ip = mkOption {
                  description = mdDoc "The ip of the node";
                  type = types.singleLineStr;
                };
                resources = mkSubmoduleOptions {
                  default = { };
                  description = mdDoc "The resources of the node";
                  types = types.attrsOf {
                    cpu = mkOption {
                      description = mdDoc "The amount of cpu cores";
                      type = types.ints.positive;
                    };
                    memory = mkOption {
                      description = mdDoc "The amount of memory in MB";
                      type = types.ints.positive;
                    };
                    storage = mkSubmoduleOptions {
                      default = { };
                      description = mdDoc "The storage of the node";
                      types = types.attrsOf {
                        disks = types.listOf {
                          description = mdDoc "The disks of the node";
                          type = types.attrsOf {
                            device = mkOption {
                              description = mdDoc "The device of the disk";
                              type = types.singleLineStr;
                            };
                            size = mkOption {
                              description = mdDoc "The size of the disk";
                              type = types.singleLineStr;
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
            pipeline = { fresh_install = mkOption { }; };
          };
        };
      };
      default = config.flake.flakeModules.nixCluster;
    };
  };
}
