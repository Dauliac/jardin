{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.jardin;
in {
  options.jardin = {
    enable = mkEnableOption "Enable jardin";
    domain = mkOption {
      type = types.str;
      default = "";
      description = "Domain for the cluster";
    };
    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug mode";
    };
    account = {
      admin = {
        group = mkOption {
          type = types.str;
          default = "admin";
          description = "Group for admin users";
        };
        users = mkOption {
          type = types.attrsOf (types.attrsOf types.str);
          default = {
            ${cfg.account.admin.group} = {};
          };
          description = "Users for the cluster";
        };
      };
    };
    self = mkOption {
      type =
        types.attrsOf
        (types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Enable the node";
            };
            networking = {
              ip = mkOption {
                type = types.str;
                description = "public ip address for the node";
              };
              record = mkOption {
                type = types.str;
                default = null;
                description = "DNS record for the node";
              };
            };
            storage = {
              disks = mkOption {
                type = types.listOf types.str;
                default = null;
                description = "List of disks path";
              };
              partitions = {
                bootSize = mkOption {
                  type = types.int;
                  default = null;
                  description = "Size of the boot partition in MiB";
                };
              };
            };
          };
        });
      default = {};
      description = "Configuration for the current node";
    };
    nodes = mkOption {
      type =
        types.attrsOf
        (types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Enable the node";
            };
            current = mkOption {
              type = types.bool;
              default = false;
              description = "Is the current node";
            };
            networking = {
              ip = mkOption {
                type = types.str;
                description = "public ip address for the node";
              };
              record = mkOption {
                type = types.str;
                default = null;
                description = "DNS record for the node";
              };
            };
            storage = {
              disks = mkOption {
                type = types.listOf types.str;
                default = null;
                description = "List of disks path";
              };
              partitions = {
                bootSize = mkOption {
                  type = types.int;
                  default = null;
                  description = "Size of the boot partition in MiB";
                };
              };
            };
          };
        });
      default = {};
      description = "Configuration for the cluster nodes";
    };
  };
}
