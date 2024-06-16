{inputs, ...}: {
  imports = [
    ./docs.nix
    ./checks.nix
    ./build.nix
  ];
  perSystem = {
    pkgs,
    self',
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
      nativeBuildInputs = with pkgs;
        [
          rust-analyzer
          go-task
          lefthook
          convco
          rust.packages.stable.rustPlatform.rustLibSrc
          fluxcd
          operator-sdk
          kind
          docker
          kubectl
          # BUG: this package is broken
          # vscode-extensions.llvm-org.lldb-vscode
        ]
        ++ config.linters
        ++ config.rustCheckers
        ++ config.formatterPackages
        ++ config.docsPackages;
      shellHook = ''
        ${config.documentationShellHookScript}
        task init
      '';
    };
  };
}
