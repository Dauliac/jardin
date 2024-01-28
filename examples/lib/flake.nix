{
  description = "My cloud";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    jardin.url = "path:../..";
  };
  outputs =
    { self
    , nixpkgs
    , jardin
    , ...
    }:
    let
      pkgs = nixpkgs.x86_64-linux;
      nixosConfig = import ./configuration.nix;
      nixos = pkgs.nixos (nixosConfig // { configuration = nixosConfig; });
      nixCluster = rec {
        cluster = {
          surname = "cluster";
          domain = "my.domain";
          nodes = {
            node1 = {
              role = "node";
              ip = "192.168.21.21";
              resources = {
                cpu = 2;
                memory = 1024;
                storage = {
                  disks = [
                    {
                      device = "/dev/sda";
                      sizeGib = "10Gib";
                    }
                  ];
                };
              };
            };
          };
        };
        pipeline.jobs = jardin.lib.x86_64-linux.deploy { config = cluster; };
      };
    in
    {
      inherit nixCluster;
      packages.x86_64-linux.domainJson =
        jardin.lib.x86_64-linux.serialize { config = nixCluster.cluster; };
    };
}
