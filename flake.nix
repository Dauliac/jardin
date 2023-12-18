# SPDX-License-Identifier: AGPL-3.0-or-later
{
  description = "Jardin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-analyzer-src.follows = "";
    };
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self
    , flake-parts
    , terranix
    , disko
    , ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (_:
    let
      # NOTE: This is boilerplate to allow us to keep the `lib`
      # output.
      libOutputModule = { lib, ... }:
        flake-parts.lib.mkTransposedPerSystemModule {
          name = "lib";
          option = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.anything;
            default = { };
          };
          file = "";
        };
      flakeOutputModule = { lib, ... }:
        flake-parts.lib.mkTransposedPerSystemModule {
          name = "flakeModule";
          option = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.anything;
            default = { };
          };
          file = "";
        };
    in
    {
      systems = [ "x86_64-linux" ];
      imports = [ libOutputModule flakeOutputModule ./nix ];
    });
}
