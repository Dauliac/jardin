{
  description = "Jardin";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    deploy-rs.url = "github:serokell/deploy-rs";
    nix-snapshotter = {
      url = "github:pdtpartners/nix-snapshotter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    disko,
    deploy-rs,
    valeMicrosoft,
    valeWriteGood,
    valeJoblint,
    nix-snapshotter,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (_: {
      systems = ["x86_64-linux"];
      imports = [
        ./infrastructure-as-code
        ./build-system
        ./tests/e2e/nixos
      ];
    });
}
