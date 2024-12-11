{...}: {
  imports = [
    ./docs.nix
  ];
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs;
        [
          go-task
          lefthook
          convco
          fluxcd
          kind
          docker
          kubectl
          sops
          kubernetes-helm
          k9s
        ]
        ++ config.formatterPackages
        ++ config.docsPackages;
      shellHook = ''
        ${config.documentationShellHookScript}
      '';
    };
  };
}
