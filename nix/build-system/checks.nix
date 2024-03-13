# SPDX-License-Identifier: AGPL-3.0-or-later
{ inputs, ... }: {
  perSystem =
    { system
    , inputs'
    , config
    , pkgs
    , ...
    }: {
      packages.coverage = config.compiler.cargoLlvmCov {
        cargoArtifacts = config.dependencies;
        src = config.sources;
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
            ${pkgs.go-task}/bin/task lint
          '';
        };
        yamlfmt = pkgs.mkShell {
          buildInputs = with pkgs; [ yamlfmt ];
          shellHook = ''
            ${pkgs.yamlfmt}/bin/yamlfmt -lint
          '';
        };
        reuse = pkgs.mkShell {
          buildInputs = with pkgs; [ reuse ];
          shellHook = ''
            ${pkgs.reuse}/bin/reuse lint
          '';
        };
        deny = pkgs.mkShell {
          cargoArtifacts = config.dependencies;
          buildInputs = with pkgs; [ cargo-deny ];
          shellHook = ''
            cargo deny check
          '';
        };
        cargo-fmt = config.compiler.cargoFmt { src = config.sources; };
        audit = config.compiler.cargoAudit {
          inherit (inputs) advisory-db;
          src = config.sources;
        };
        # TODO: fix clippy
        # clippy = config.compiler.cargoClippy ({
        #   cargoArtifacts = dependencies;
        #   cargoClippyExtraArgs = "-- --deny warnings";
        #   src = compile.sources;
        # });
        coverage = config.compiler.cargoLlvmCov {
          src = config.sources;
          cargoArtifacts = config.dependencies;
          buildInputs = [ config.toolchain pkgs.cargo-nextest ];
          cargoLlvmCovCommand = "nextest";
        };
      };
    };
}
