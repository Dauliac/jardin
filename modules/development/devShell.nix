{ inputs, ... }: {
  perSystem =
    { system
    , pkgs
    , self'
    , ...
    }:
    let
      compile = import ../build-system/compile.nix { inherit inputs system; };
      formatterPackages =
        import ./../build-system/formatter-dependencies.nix { inherit pkgs; };
    in
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self'.checks;

        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

        nativeBuildInputs = with pkgs;
          [
            compile.toolchain
            rust-analyzer
            go-task
            lefthook
            cargo-udeps
            rust.packages.stable.rustPlatform.rustLibSrc
            # BUG: this package is broken
            # vscode-extensions.llvm-org.lldb-vscode
          ]
          ++ formatterPackages;
        shellHook = ''
          export GAMBLE_TEST_COMMAND="true" # replace `true` with the command to run your tests
        '';
      };
    };
}
