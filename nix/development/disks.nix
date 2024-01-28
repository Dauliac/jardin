{ disks ? [ "/dev/vda" ], ... }:
let
  format = { disk }: {
    type = "disk";
    device = disk;
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "boot";
          start = "0";
          end = "1MiB";
          part-type = "primary";
          flags = [ "bios_grub" ];
        }
        {
          name = "ESP";
          start = "1MiB";
          end = "128MiB";
          fs-type = "fat32";
          bootable = true;
          content = {
            type = "mdraid";
            name = "boot";
          };
        }
        {
          name = "root";
          start = "128MiB";
          end = "-6GiB";
          content = {
            type = "mdraid";
            name = "raid1-root";
          };
        }
        {
          name = "swap";
          start = "-6GiB";
          end = "100%";
          part-type = "primary";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        }
      ];
    };
  };
in
{
  disk = { one = format { disk = builtins.elemAt disks 0; }; };
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
    raid1-root = {
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "btrfs";
        mountpoint = "/";
      };
    };
  };
}
