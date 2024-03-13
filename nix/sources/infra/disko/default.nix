# SPDX-License-Identifier: AGPL-3.0-or-later
{ lib
, config
, ...
}:
let
  inherit (lib) mkOption mdDoc mkIf;
  cfg = config.infra.disko;
  disks = config.domain.cluster.storage.disk;
in
{
  options = {
    infra.disko = {
      enable = mkOption {
        description = mdDoc "Enable disko.";
        default = false;
      };
      mkDiskoLayout = mkOption {
        description = mdDoc "Function to create disko config layout.";
        default = node:
          let
            rootRaidName = "raid1-root";
          in
          {
            disk =
              builtins.listToAttrs
                (builtins.map (disk: {
                  name = disk.device;
                  value = {
                    type = "disk";
                    inherit (disk) device;
                    content = {
                      type = "table";
                      format = "msdos";
                      partitions = [
                        {
                          name = "boot";
                          part-type = "primary";
                          start = "${disk.mkBootPartitionStart node}MiB";
                          end = "${disk.mkBootPartitionEnd node}MiB";
                          # TODO: check if we need to change it in function of node.uefi
                          flags = [ "bios_grub" ];
                        }
                        {
                          name = "root";
                          part-type = "primary";
                          start = "${disk.mkRootPartitionStart node.partitions.root}MiB";
                          end = "${disk.mkRootPartitionEnd node.partitions.root}MiB";
                          bootable = true;
                          content = {
                            type = "mdraid";
                            name = rootRaidName;
                          };
                        }
                        {
                          name = "swap";
                          start = "${disk.mkSwapPartitionStart node.partitions.swap}MiB";
                          end = "${disk.mkSwapPartitionEnd node.partitions.swap}MiB";
                          content = {
                            type = "swap";
                            randomEncryption = true;
                          };
                        }
                      ];
                    };
                  };
                }))
                node.disks;
            mdadm = {
              boot = {
                type = "mdadm";
                level = 1;
                metadata = "1.0";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              ${rootRaidName} = {
                type = "mdadm";
                level = 1;
                content = {
                  type = "filesystem";
                  format = "btrfs";
                  mountpoint = "/";
                };
              };
            };
          };
      };
      disksLayout = mkOption {
        # TODO: use attrsSet of nodes container disko layout type as type
        description = mdDoc "Disko disks layout.";
      };
    };
  };
  config = {
    flake = { lib.infra.disko = cfg; };
    infra.disko.disksLayout =
      mkIf cfg.enable
        (builtins.mapAttrs (node: (cfg.mkDiskoLayout node)) disks.nodes);
  };
}
