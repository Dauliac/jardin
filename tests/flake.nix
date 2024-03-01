{
  description = "A flake with jardin";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jardin.url = "path:../";
  };
  outputs =
    inputs @ { self
    , flake-parts
    , jardin
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      imports = [ inputs.jardin.flakeModules.default ];
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      # flake.nixCluster = {
      #   cluster = {
      #     name = "cluster";
      #     dns = {
      #       zone = "my.domain";
      #       provider = "cloudflare";
      #     };
      #     nodes = {
      #       node1 = {
      #         role = "node";
      #         ip = "192.168.21.21";
      #         resources = {
      #           cpu = 2;
      #           memory = 1024;
      #           storage = {
      #             disks = [{
      #               device = "/dev/sda";
      #               size = "10Gb";
      #             }];
      #           };
      #         };
      #       };
      #     };
      #   };
      #   perSystem = { config, self', inputs', pkgs, ... }: {
      #     packages.hello = pkgs.hello;
      #   };
      # };
    });
}
