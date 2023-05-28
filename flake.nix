# SPDX-License-Identifier: AGPL-3.0-or-later
{
  description = "Jardin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-analyzer-src.follows = "";
    };

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , crane
    , fenix
    , advisory-db
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        # overlays = [ (import fenix) ];
      };

      craneLib = crane.lib.${system};
      src = craneLib.cleanCargoSource (craneLib.path ./.);
      commonArgs = {
        inherit src;
      };
      cargoArtifacts = craneLib.buildDepsOnly commonArgs;

      jardin =
        let
          craneLib =
            crane.lib.${system}.overrideToolchain
              fenix.packages.${system}.complete.toolchain;
        in
        craneLib.buildPackage (commonArgs
          // {
          inherit cargoArtifacts;
        });

      formatterPackages = with pkgs; [
        nixpkgs-fmt
        alejandra
        statix
      ];
    in
    {
      packages.default = jardin;

      formatter =
        pkgs.writeShellApplication
          {
            name = "normalise_nix";
            runtimeInputs = formatterPackages;
            text = ''
              set -o xtrace
              alejandra "$@"
              nixpkgs-fmt "$@"
              statix fix "$@"
            '';
          };

      checks = {
        inherit jardin;
        # TODO: add cargo-audit, and lot of other checks

        typos = pkgs.mkShell {
          buildInputs = with pkgs; [ typos ];
          shellHook = ''
            typos .
          '';
        };
        yamllint = pkgs.mkShell {
          buildInputs = with pkgs; [ yamllint ];
          shellHook = ''
            yamllint --strict .
          '';
        };
        reuse = pkgs.mkShell {
          buildInputs = with pkgs; [ reuse ];
          shellHook = ''
            reuse lint
          '';
        };

        cargo-fmt = craneLib.cargoFmt {
          inherit src;
        };

        audit = craneLib.cargoAudit {
          inherit src advisory-db;
        };

        clippy = craneLib.cargoClippy (commonArgs
          // {
          inherit cargoArtifacts;
          # TODO: fix code for clippy
          # cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          cargoClippyExtraArgs = "--all-targets";
        });

        coverage = craneLib.cargoTarpaulin (commonArgs
          // {
          inherit cargoArtifacts;
        });
      };

      devShells.default =
        pkgs.mkShell
          {
            inputsFrom = builtins.attrValues self.checks.${system};

            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            nativeBuildInputs = with pkgs;
              [
                go-task
                lefthook
                rustc
                rustfmt
                rust.packages.stable.rustPlatform.rustLibSrc
              ]
              ++ formatterPackages;
          };
    });
}
