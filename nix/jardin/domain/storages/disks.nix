{ flake-parts-lib
, lib
, config
, ...
}:
let
  inherit (lib) mkOption types mkIf mdDoc;
  inherit (flake-parts-lib) mkSubmoduleOptions;
  cfg = config.domain.cluster.storage;
  inherit (config.domain) cluster;
in
{
  options = {
    domain.cluster.storage = {
      lib = {
        mkBootSize = mkOption {
          description = mdDoc "Boot partition size for a node";
          default = node:
            let
              baseSize =
                if node.uefi
                then cfg.boot.uefiClaimSize
                else cfg.boot.nonUefiClaimSize;
            in
            baseSize + (cfg.numberOfKernels * cfg.boot.perKernelSize);
        };
        mkTotalSize = mkOption {
          description = mdDoc "Compute the all available size of the node";
          default = node:
            lib.foldl' (acc: disk: acc + disk.sizeGb * 1000) 0 node.disks;
        };
        mkSwapSize = mkOption {
          description = mdDoc "Swap partition size for a node";
          default = node:
            let
              storage = cfg.lib.mkTotalSize node;
              halfMemory = node.memory / 2;
              baseSwap =
                if node.memory < 2048
                then node.memory
                else if node.memory <= 8192
                then halfMemory
                else cfg.swap.maxSize;
              additionalStorageSwap = storage / 10;
            in
            baseSwap + additionalStorageSwap;
        };
        mkRootSize = mkOption {
          description = mdDoc "Root partition size for a node";
          default = node:
            (cfg.lib.mkTotalSize node)
            - (cfg.lib.mkBootSize node)
            - (cfg.lib.mkSwapSize node);
        };
        mkNodes = mkOption {
          description = mdDoc "The list of nodes";
          default = nodes:
            lib.mapAttrsToList
              (name: node: {
                inherit name;
                inherit (node) memory;
                inherit (node) disks;
                inherit (node) uefi;
                inherit (node) numberOfKernels;
                boot = cfg.mkBootSize node;
                swap = cfg.mkSwapSize node;
                root = cfg.mkRootSize node;
              })
              nodes;
        };
      };
      boot = {
        perKernelSize = mkOption {
          description = mdDoc "The size of the kernel";
          type = types.ints.positive;
          default = 25;
        };
        uefiClaimSize = mkOption {
          description = mdDoc "The size of the uefi partition";
          type = types.ints.positive;
          default = 300;
        };
        nonUefiClaimSize = mkOption {
          description = mdDoc "The size of the non uefi partition";
          type = types.ints.positive;
          default = 100;
        };
      };
      swap = {
        maxSize = mkOption {
          description = mdDoc "The base size of the swap";
          type = types.ints.positive;
          default = 4096;
        };
      };
      numberOfKernels = mkOption {
        description = mdDoc "The number of kernels to keep";
        type = types.ints.positive;
        default = 2;
      };
      nodes = mkOption {
        description = mdDoc "Nodes storage information";
        type = types.attrsOf (types.submodule (_: {
          options = {
            memory = mkOption {
              description = mdDoc "The amount of memory in MB";
              type = types.ints.positive;
            };
            disks = mkOption {
              description = mdDoc "The list of disks";
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
            partitions = {
              boot = mkOption {
                description = mdDoc "The size of the boot partition";
                type = types.ints.positive;
              };
              root = mkOption {
                description = mdDoc "The size of the root partition";
                type = types.ints.positive;
              };
              swap = mkOption {
                description = mdDoc "The size of the swap partition";
                type = types.ints.positive;
              };
            };
            uefi = mkOption {
              description = mdDoc "Is the node have uefi";
              type = types.bool;
            };
          };
        }));
      };
    };
  };
  config = {
    domain.cluster.storage = {
      nodes =
        builtins.mapAttrs
          (name: clusterNode:
            let
              node = {
                inherit (clusterNode.resources) memory;
                disks =
                  builtins.map
                    (disk: {
                      inherit (disk) device;
                      inherit (disk) sizeGb;
                    })
                    clusterNode.resources.storage.disks;
                inherit (clusterNode.resources.storage) uefi;
              };
              node.partitions = {
                boot = cfg.lib.mkBootSize node;
                root = cfg.lib.mkRootSize node;
                swap = cfg.lib.mkSwapSize node;
              };
            in
            node)
          cluster.nodes;
    };
  };
}
