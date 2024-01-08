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
<<<<<<< HEAD
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
||||||| parent of 565b713 (feat(modules-sources): poc to define protocol between nix and jardin tasks)
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [./modules/default.nix];
=======
  };
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ ./modules/default.nix ];
>>>>>>> 565b713 (feat(modules-sources): poc to define protocol between nix and jardin tasks)
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
