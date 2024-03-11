# SPDX-License-Identifier: AGPL-3.0-or-later
{inputs, ...}: {
  perSystem = {
    system,
    inputs',
    pkgs,
    ...
  }: let
    compile = import ./compile.nix {inherit inputs system;};
    deps = compile.dependencies;
  in {
    packages.coverage = compile.compiler.cargoLlvmCov {
      cargoArtifacts = deps;
      src = compile.sources;
      cargoExtraArgs = "nextest";
    };
    checks = {
      # TODO: write function to inherit all tests in checks
      inherit
        (package.test.infra.nixOs)
        ;
      lint = pkgs.mkShell {
        buildInputs = with pkgs; [
          typos
          go-task
          reuse
          yamlfmt
        ];
        shellHook = ''
          task lint
        '';
      };
      yamlfmt = pkgs.mkShell {
        buildInputs = with pkgs; [yamlfmt];
        shellHook = ''
          yamlfmt -lint
        '';
      };
      reuse = pkgs.mkShell {
        buildInputs = with pkgs; [reuse];
        shellHook = ''
          reuse lint
        '';
      };
      deny = pkgs.mkShell {
        cargoArtifacts = deps;
        buildInputs = with pkgs; [cargo-deny];
        shellHook = ''
          cargo deny check
        '';
      };
      cargo-fmt = compile.compiler.cargoFmt {src = compile.sources;};
      audit = compile.compiler.cargoAudit {
        inherit (inputs) advisory-db;
        src = compile.sources;
      };
      # TODO: fix clippy
      # clippy = compile.compiler.cargoClippy ({
      #   cargoArtifacts = deps;
      #   cargoClippyExtraArgs = "-- --deny warnings";
      #   src = compile.sources;
      # });
      coverage = compile.compiler.cargoLlvmCov {
        src = compile.sources;
        cargoArtifacts = deps;
        buildInputs = [compile.toolchain pkgs.cargo-nextest];
        cargoLlvmCovCommand = "nextest";
      };
    };
  };
}
