# SPDX-License-Identifier: AGPL-3.0-or-later
{
  description = "Jardin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
    valeMicrosoft = {
      url = "github:errata-ai/Microsoft";
      flake = false;
    };
    valeWriteGood = {
      url = "github:errata-ai/write-good";
      flake = false;
    };
    valeJoblint = {
      url = "github:errata-ai/Joblint";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    terranix,
    disko,
    valeMicrosoft,
    valeWriteGood,
    valeJoblint,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (_: {
      systems = ["x86_64-linux"];
      imports = [./nix];
    });
}
