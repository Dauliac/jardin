{
  config,
  lib,
  pkgs,
  jardinLib,
  ...
}: let
  inherit (lib) mkIf;
  currentNode = jardinLib.findCurrentNode config.jardin.nodes;
  format = disk: (builtins.replaceStrings ["/"] ["-"] disk);
  formatted =
    lib.lists.imap0
    (_: value: {
      name = format value;
      inherit value;
    })
    currentNode.storage.disks;
  firstDisk = builtins.head formatted;
  rootPartition = {
    zfs = {
      size = "100%";
      content = {
        type = "zfs";
        pool = "zroot";
      };
    };
  };
  disks =
    builtins.mapAttrs
    (name: value: {
      device = value;
      type = "disk";
      content = {
        type = "gpt";
        partitions = rootPartition;
      };
    })
    (builtins.listToAttrs (lib.lists.drop 1 formatted));
in {
  disko.devices = mkIf (currentNode.storage.disks != null && (currentNode.storage.partitions.bootSize != null)) {
    disk =
      disks
      // {
        ${firstDisk.name} = {
          type = "disk";
          device = firstDisk.value;
          content = {
            type = "gpt";
            partitions =
              {
                ESP = {
                  size = "${currentNode.storage.partitions.bootSize}Mib";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
              }
              // rootPartition;
          };
        };
      };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "raidz2";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
        datasets = {
          log = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options.mountpoint = "legacy";
            postCreateHook = "zfs snapshot zroot/root@blank";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          persistent = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persistent";
          };
          home = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
        };
      };
    };
  };
  environment.systemPackages = [
    pkgs.zfs
  ];
  boot.kernelPackages = mkIf (currentNode.storage.disks != null && (currentNode.storage.partitions.bootSize != null)) config.boot.zfs.package.latestCompatibleLinuxPackages;
  networking.hostId =
    mkIf (currentNode.storage.disks != null && (currentNode.storage.partitions.bootSize != null))
    (builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName));
}
