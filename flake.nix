{
  description = "Jardin";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-snapshotter = {
      url = "github:pdtpartners/nix-snapshotter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
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
    disko,
    valeMicrosoft,
    valeWriteGood,
    valeJoblint,
    nix-snapshotter,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (_: {
      systems = ["x86_64-linux"];
      imports = [
        ./nix
        ./tests/e2e/nixos
      ];
    });
}
