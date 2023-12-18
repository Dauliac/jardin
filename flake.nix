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
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-analyzer-src.follows = "";
    };
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, crane, fenix, advisory-db, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        craneLib = crane.lib.${system};
        src = craneLib.cleanCargoSource (craneLib.path ./.);
        commonArgs = { inherit src; };

        fenix-channel = fenix.packages.${system}.latest;

        toolchain = fenix-channel.withComponents [
          "rustc"
          "cargo"
          "clippy"
          "rust-analysis"
          "rust-src"
          "rustfmt"
          "llvm-tools-preview"
        ];

        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

        jardinPackage =
          let craneLib = crane.lib.${system}.overrideToolchain toolchain;
          in craneLib.buildPackage (commonArgs // { inherit cargoArtifacts; });

        formatterPackages = with pkgs; [ nixpkgs-fmt alejandra statix ];
      in
      {
        packages = rec {
          jardin = jardinPackage;
          default = jardin;
          lib = { iac = (import ./iac/default.nix { inherit pkgs; }).lib; };
        };
        apps = rec {
          jardin =
            flake-utils.lib.mkApp { drv = self.packages.${system}.jardin; };
          default = jardin;
          iac = { iac = (import ./iac/default.nix pkgs).lib; };
        };

        packages.coverage = craneLib.cargoLlvmCov (commonArgs // {
          inherit cargoArtifacts;
          cargoExtraArgs = "nextest";
        });

        formatter = pkgs.writeShellApplication {
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
          inherit jardinPackage;
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
          deny = pkgs.mkShell {
            inherit cargoArtifacts;
            buildInputs = with pkgs; [ cargo-deny ];
            shellHook = ''
              cargo deny check
            '';
          };
          cargo-fmt = craneLib.cargoFmt { inherit src; };
          audit = craneLib.cargoAudit { inherit src advisory-db; };
          clippy = craneLib.cargoClippy (commonArgs // {
            inherit cargoArtifacts;
            # TODO: fix code for clippy
            cargoClippyExtraArgs = "-- --deny warnings";
          });
          coverage = craneLib.cargoLlvmCov (commonArgs // {
            inherit cargoArtifacts;
            nativeBuildInputs = [ toolchain pkgs.cargo-nextest ];
            cargoLlvmCovCommand = "nextest";
          });
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.checks.${system};

          RUST_SRC_PATH =
            "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

          nativeBuildInputs = with pkgs;
            [
              toolchain
              rust-analyzer
              go-task
              lefthook
              rustc
              cargo-udeps
              rustfmt
              rust.packages.stable.rustPlatform.rustLibSrc
              # BUG: this package is broken
              # vscode-extensions.llvm-org.lldb-vscode
            ] ++ formatterPackages;
          shellHook = ''
            export GAMBLE_TEST_COMMAND="true" # replace `true` with the command to run your tests
          '';
        };
      });
}
