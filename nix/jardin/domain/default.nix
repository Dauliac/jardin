{ flake-parts-lib
, lib
, config
, pkgs
, inputs
, ...
}:
let
  inherit (builtins) mapAttrs;
  inherit (lib) mkOption types mkIf mkMerge mdDoc;
  inherit (flake-parts-lib) mkSubmoduleOptions;
  cfg = config.domain;
in
{
  imports = [ ./networks ./storages ];
  options = {
    domain.cluster = {
      domain = mkOption {
        description = mdDoc "The root dns zone of your cluster";
        type = types.singleLineStr;
      };
      nodes = mkOption {
        description = mdDoc "The cluster's nodes";
        type = types.attrsOf (types.submodule (_: {
          options = {
            role = mkOption {
              description = mdDoc "";
              type = types.enum [ "node" ];
            };
            ip = mkOption {
              description = mdDoc "";
              type = types.singleLineStr;
            };
            resources = mkOption {
              default = null;
              description = mdDoc "";
              type = types.submodule ({ config, ... }: {
                options = {
                  cpu = mkOption {
                    description = mdDoc "";
                    type = types.ints.positive;
                  };
                  memory = mkOption {
                    description = mdDoc "";
                    type = types.ints.positive;
                  };
                  storage = {
                    disks = mkOption {
                      description = mdDoc "The disks of the node";
                      type = types.listOf (types.submodule (_: {
                        options = {
                          device = mkOption {
                            description = mdDoc "The device of the disk";
                            type = types.singleLineStr;
                          };
                          sizeGb = mkOption {
                            description = mdDoc "The size of the disk";
                            type = types.ints.positive;
                          };
                        };
                      }));
                    };
                    uefi = mkOption {
                      description = mdDoc "Is the node have uefi";
                      type = types.bool;
                    };
                  };
                };
              });
            };
          };
        }));
      };
    };
  };
  config = {
    # TODO: remove this test code
    domain.cluster = {
      domain = "demo.org";
      nodes = {
        foo = {
          ip = "localhost";
          resources = {
            cpu = 1;
            memory = 1024;
            storage = {
              disks = [
                {
                  device = "/dev/sda";
                  sizeGb = 20;
                }
              ];
              uefi = false;
            };
          };
        };
        bar = {
          ip = "localhost";
          resources = {
            cpu = 1;
            memory = 1024;
            storage = {
              disks = [
                {
                  device = "/dev/sda";
                  sizeGb = 20;
                }
              ];
              uefi = false;
            };
          };
        };
      };
    };
    flake = { lib.domain = cfg; };
  };
}
