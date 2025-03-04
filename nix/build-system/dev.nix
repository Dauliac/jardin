{ ... }:
{
  imports = [
    ./docs.nix
  ];
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs =
          with pkgs;
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
            comin
            deadnix
            sops
          ]
          ++ config.docsPackages;
        shellHook = ''
          export SOPS_AGE_KEY_FILE=~/.config/sops/age/dotfiles.txt
          ${config.documentationShellHookScript}
        '';
      };
      apps = {
        devOsStart = {
          type = "app";
          program = pkgs.writeScriptBin "dev-os-connect" ''
            #!${pkgs.bash}/bin/bash
            set -o errexit
            set -o nounset
            set -o pipefail
            rm -rf /tmp/jardin
            declare -gx repo_path
            repo_path=$(git rev-parse --show-toplevel)
            cp -rf $repo_path /tmp/jardin
            ${config.packages.devOs}/bin/start
          '';
        };
        devOsConnect = {
          type = "app";
          program = pkgs.writeScriptBin "dev-os-connect" ''
            #!${pkgs.bash}/bin/bash
            set -o errexit
            set -o nounset
            set -o pipefail
            ${config.packages.devOs}/bin/ssh
          '';
        };
      };
    };
}
