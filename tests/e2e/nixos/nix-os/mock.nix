_: {
  documentation.enable = false;
  virtualisation = {
    diskSize = 2048;
    graphics = false;
  };
  jardin = {
    enable = true;
    debug = true;
    nodes = {
      test = {
        current = true;
        networking = {
          ip = "192.10.1.1";
        };
        storage = {
          disks = [
            "/dev/sda"
          ];
          partitions.bootSize = 512;
        };
      };
    };
  };
}
