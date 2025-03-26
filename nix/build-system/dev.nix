{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      inputs',
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
            cloudflared
          ]
          ++ [
            inputs'.nix-fast-build.packages.nix-fast-build
          ];
        shellHook = ''
          export SOPS_AGE_KEY_FILE="$(git rev-parse --show-toplevel)/age.txt"
          rm -rf .json-schema
          mkdir -p .json-schema
          ln -sf ${inputs.json-schema-kube-catalog} .json-schema/kube
          ln -sf ${inputs.json-schema-crds-catalog} .json-schema/crds-catalog
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
        check = {
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
