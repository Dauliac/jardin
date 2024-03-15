{
  lib,
  inputs,
  config,
  ...
}: let
  inherit (lib) mkOption mdDoc types;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in {
  options = {
    perSystem = mkPerSystemOption ({
      config,
      lib',
      pkgs,
      system,
      ...
    }: {
      options = {
        fenixPackage = mkOption {
          description = mdDoc "Fenix package";
          type = types.package;
        };
        toolchain = mkOption {
          description = mdDoc "Rust toolchain";
          type = types.package;
        };
        craneLib = mkOption {
          description = mdDoc "Crane library";
        };
        compiler = mkOption {
          description = mdDoc "Rust toolchain with crane library boilerplate";
        };
        sources = mkOption {
          description = mdDoc "Rust sources";
          type = types.package;
        };
        dependencies = mkOption {
          description = mdDoc "Rust crates from cargo";
          type = types.package;
        };
        artifact = mkOption {
          description = mdDoc "Built rust artifact";
          type = types.package;
        };
      };
    });
  };
  config = {
    perSystem = {
      config,
      system,
      ...
    }: {
      fenixPackage = inputs.fenix.packages.${system}.latest;
      toolchain = config.fenixPackage.withComponents [
        "rustc"
        "cargo"
        "clippy"
        "rust-analysis"
        "rust-src"
        "rustfmt"
        "llvm-tools-preview"
      ];
      craneLib = inputs.crane.lib.${system};
      compiler = config.craneLib.overrideToolchain config.toolchain;
      sources = config.compiler.cleanCargoSource (config.craneLib.path ./../../.);
      dependencies = config.compiler.buildDepsOnly {src = config.sources;};
      artifact = config.compiler.buildPackage {
        inherit (config) dependencies;
        src = config.sources;
      };
    };
  };
}
