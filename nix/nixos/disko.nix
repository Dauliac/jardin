_: {
  disko.devices = {
    disk = {
      data = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                mountpoint = "/mnt/data";
                extraArgs = [
                  "-f"
                ];
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
}
