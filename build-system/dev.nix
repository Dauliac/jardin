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
          sops
        ]
        ++ config.linters
        ++ config.rustCheckers
        ++ config.formatterPackages
        ++ config.docsPackages;
      shellHook = ''
        ${config.documentationShellHookScript}

        export FLAKE_ROOT="$(git rev-parse --show-toplevel)"
        export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/jardin.txt"
        task \
          --taskfile "$FLAKE_ROOT/Taskfile.yaml" \
          init
      '';
    };
  };
}
