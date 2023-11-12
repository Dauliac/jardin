{
  description = "My cloud";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { self
    , nixpkgs
    , ...
    }:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      jardin = {
        pipeline = { };
        cluster = {
          surname = "cluster";
          domain = "my.domain";
          targets = {
            node1 = {
              hostname = "node1";
              role = "node";
              ip = "192.168.21.21";
            };
          };
        };
      };
    }

