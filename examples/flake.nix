{
  description = "My cloud";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    jardin.url = "path:..";
  };
  outputs = { self, nixpkgs, jardin, ... }: {
    nixCluster = rec {
      pipeline.jobs = jardin.lib.x86_64-linux.deploy { inherit cluster; };
      cluster = {
        surname = "cluster";
        domain = "my.domain";
        targets = {
          node1 = {
            hostname = "node2";
            role = "node";
            ip = "192.168.21.21";
          };
          node2 = {
            hostname = "node2";
            role = "node";
            ip = "192.168.21.21";
          };
        };
      };
    };
  };
}
