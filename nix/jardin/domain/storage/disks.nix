{ flake-parts-lib
, lib
, config
, ...
}:
let
  inherit (lib) mkOption types mkIf mdDoc;
  inherit (flake-parts-lib) mkSubmoduleOptions;
  cfg = config.domain.cluster.storage.disk;
  inherit (config.domain) cluster;
in
{
  options = {
    domain.cluster.storage.disk = {
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
          lib.foldl' (acc: disk: acc + (cluster.types.convertToMiB disk.size)) 0
            node.disks;
      };
      mkSwapSize = mkOption {
        description = mdDoc "Swap partition size for a node";
        default = node:
          let
            storage = cfg.mkTotalSize node;
            memory = cluster.types.convertToMiB node.memory;
            halfMemory = memory / 2;
            baseSwap =
              if memory < 2048
              then memory
              else if memory <= 8192
              then halfMemory
              else cfg.swap.maxSize;
            additionalStorageSwap = storage / 10;
          in
          baseSwap + additionalStorageSwap;
      };
      mkRootSize = mkOption {
        description = mdDoc "Root partition size for a node";
        default = node:
          (cfg.mkTotalSize node)
          - (cfg.mkBootSize node)
          - (cfg.mkSwapSize node);
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
              boot =
                cluster.types.convertMiBTodigitalStorageUnit
                  (cfg.mkBootSize node);
              swap =
                cluster.types.convertMiBTodigitalStorageUnit
                  (cfg.mkSwapSize node);
              root =
                cluster.types.convertMiBTodigitalStorageUnit
                  (cfg.mkRootSize node);
            })
            nodes;
      };
      boot = {
        perKernelSize = mkOption {
          description = mdDoc "The size of the kernel";
          type = cluster.types.digitalStorageUnit;
          default = "25MB";
        };
        uefiClaimSize = mkOption {
          description = mdDoc "The size of the uefi partition";
          type = cluster.types.digitalStorageUnit;
          default = "300MB";
        };
        nonUefiClaimSize = mkOption {
          description = mdDoc "The size of the non uefi partition";
          type = cluster.types.digitalStorageUnit;
          default = "100MB";
        };
      };
      swap = {
        maxSize = mkOption {
          description = mdDoc "The base size of the swap";
          type = cluster.types.digitalStorageUnit;
          default = "4096MB";
        };
      };
      numberOfKernels = mkOption {
        description = mdDoc "The number of kernels to keep in boot partition";
        type = types.ints.positive;
        default = 2;
      };
      nodes = mkOption {
        description = mdDoc "Nodes storage information";
        type = types.attrsOf (types.submodule (_: {
          options = {
            memory = mkOption {
              description = mdDoc "The amount of ramdom access memory";
              type = cluster.types.digitalStorageUnit;
            };
            disks = mkOption {
              description = mdDoc "The list of disks";
              type = types.listOf (types.submodule (_: {
                options = {
                  device = mkOption {
                    description = mdDoc "The device of the disk";
                    type = types.singleLineStr;
                  };
                  size = mkOption {
                    description = mdDoc "The size of the disk";
                    type = cluster.types.digitalStorageUnit;
                  };
                };
              }));
            };
            partitions = {
              boot = mkOption {
                description = mdDoc "The size of the boot partition";
                type = cluster.types.digitalStorageUnit;
              };
              root = mkOption {
                description = mdDoc "The size of the root partition";
                type = cluster.types.digitalStorageUnit;
              };
              swap = mkOption {
                description = mdDoc "The size of the swap partition";
                type = cluster.types.digitalStorageUnit;
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
    domain.cluster.storage.disk = {
      nodes =
        builtins.mapAttrs
          (name: clusterNode:
            let
              node = {
                memory =
                  cluster.types.convertMiBTodigitalStorageUnit
                    clusterNode.resources.memory;
                disks =
                  builtins.map
                    (disk: {
                      inherit (disk) device;
                      size = cluster.types.convertMiBTodigitalStorageUnit disk.size;
                    })
                    clusterNode.resources.storage.disks;
                inherit (clusterNode.resources.storage) uefi;
              };
              node.partitions = {
                boot =
                  cluster.types.convertMiBTodigitalStorageUnit
                    (cfg.mkBootSize node);
                root =
                  cluster.types.convertMiBTodigitalStorageUnit
                    (cfg.mkRootSize node);
                swap =
                  cluster.types.convertMiBTodigitalStorageUnit
                    (cfg.mkSwapSize node);
              };
            in
            node)
          cluster.nodes;
    };
  };
}
