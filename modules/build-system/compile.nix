{ inputs
, system
,
}:
let
  fenixPackage = inputs.fenix.packages.${system}.latest;
  toolchain = fenixPackage.withComponents [
    "rustc"
    "cargo"
    "clippy"
    "rust-analysis"
    "rust-src"
    "rustfmt"
    "llvm-tools-preview"
  ];
  craneLib = inputs.crane.lib.${system};
  compiler = craneLib.overrideToolchain toolchain;
  sources = compiler.cleanCargoSource (craneLib.path ./../../.);
  dependencies = compiler.buildDepsOnly { src = sources; };
  artifact = compiler.buildPackage {
    inherit dependencies;
    src = sources;
  };
in
{ inherit dependencies artifact toolchain compiler sources; }
