{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption mdDoc types;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in {
  imports = [
    ./compile.nix
  ];
  options.perSystem = mkPerSystemOption ({
    pkgs,
    config,
    ...
  }: {
    options = {
      linters = mkOption {
        description = mdDoc "Packages used to lint the repo";
        type = types.listOf types.package;
        default = with pkgs; [
          typos
          go-task
          reuse
          yamlfmt
        ];
      };
      rustCheckers = mkOption {
        description = mdDoc "Packages used to check rust";
        type = types.listOf types.package;
      };
    };
  });
  config.perSystem = {
    system,
    inputs',
    config,
    pkgs,
    ...
  }: {
    rustCheckers = with pkgs; [
      cargo-deny
      cargo-nextest
      cargo-udeps # TODO: integrate it as check
      config.toolchain
      config.dependencies
    ];
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
        buildInputs = config.linters;
        shellHook = ''
          ${pkgs.go-task}/bin/task lint
        '';
      };
      deny = pkgs.mkShell {
        cargoArtifacts = config.dependencies;
        buildInputs = config.rustCheckers;
        shellHook = ''
          cargo deny check
        '';
      };
      cargo-fmt = config.compiler.cargoFmt {src = config.sources;};
      audit = config.compiler.cargoAudit {
        inherit (inputs) advisory-db;
        src = config.sources;
      };
      # FIXME: repair clippy invocation
      # clippy = config.compiler.cargoClippy ({
      #   cargoArtifacts = dependencies;
      #   cargoClippyExtraArgs = "-- --deny warnings";
      #   src = compile.sources;
      # });
      coverage = config.compiler.cargoLlvmCov {
        src = config.sources;
        cargoArtifacts = config.dependencies;
        buildInputs = config.rustCheckers;
        cargoLlvmCovCommand = "nextest";
      };
      testE2e = pkgs.mkShell {
        buildInputs = [
          config.packages.default
          pkgs.go-task
          pkgs.bats
          pkgs.parallel
          pkgs.bash
          pkgs.fish
          pkgs.zsh
        ];
        shellHook = ''
          ${pkgs.go-task}/bin/task tests:e2e:cli
        '';
      };
    };
  };
}
