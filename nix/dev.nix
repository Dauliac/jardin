# SPDX-License-Identifier: AGPL-3.0-or-later
{ ... }: {
  imports = [
    ./build-system/docs.nix
    ./build-system/checks.nix
    ./build-system/compile.nix
  ];
  perSystem =
    { pkgs
    , self'
    , config
    , ...
    }: {
      devShells.default = pkgs.mkShell {
        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
        nativeBuildInputs = with pkgs;
          [
            config.toolchain
            rust-analyzer
            go-task
            lefthook
            convco
            mdbook
            cargo-udeps # TODO: integrate it as check
            rust.packages.stable.rustPlatform.rustLibSrc
            # BUG: this package is broken
            # vscode-extensions.llvm-org.lldb-vscode
          ]
          ++ config.formatterPackages
          ++ config.docsPackages;
        shellHook = ''
          ${config.documentationShellHookScript}
           task init
        '';
      };
    };
}
