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
          kustomize
          kubectl
          trufflehog
          fd
          yamlfmt
          reuse
          sops
          kubernetes-helm
          k9s
          kube-linter
          kubeconform
        ]
        ++ config.formatterPackages
        ++ config.docsPackages;
      shellHook = ''
        ${config.documentationShellHookScript}
      '';
    };
  };
}
