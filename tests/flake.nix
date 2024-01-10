{
  description = "Test flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    jardin.url = "path:../";
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , jardin
    ,
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      config = {
        cluster = {
          nodes = {
            node1 = { ip = ""; };
            node2 = { ip = ""; };
          };
        };
      };
      # jardinIac = jardin.lib.iac config;
      jardinIac = jardin;
    in
    {
      lib = jardinIac;
      packages.default = jardinIac;
    });
}
