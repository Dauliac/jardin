# SPDX-License-Identifier: AGPL-3.0-or-later
_: {
  perSystem =
    { pkgs
    , self'
    , config
    , ...
    }: {
      devShells.default = pkgs.mkShell {
        inputsFrom = builtins.attrValues self'.checks;
        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        nativeBuildInputs = with pkgs;
          [
            config.toolchain
            rust-analyzer
            go-task
            lefthook
            convco
            cargo-udeps
            rust.packages.stable.rustPlatform.rustLibSrc
            # TODO: move it into flake
            autoflake
            # BUG: this package is broken
            # vscode-extensions.llvm-org.lldb-vscode
          ]
          ++ config.formatterPackages;
        shellHook = ''
          export GAMBLE_TEST_COMMAND="true" # replace `true` with the command to run your tests
        '';
      };
    };
}
