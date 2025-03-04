{ inputs, ... }:
{
  config.perSystem =
    {
      config,
      inputs',
      pkgs,
      ...
    }:
    {
      checks = {
        devOs =
          pkgs.runCommand "build-dev-os"
            {
              buildInputs = [
                config.packages.devOs
              ];
            }
            ''
              cp -r ${config.packages.devOs} $out
            '';

        linter =
          pkgs.runCommand "build-scripts"
            {
              buildInputs = with pkgs; [
                go-task
                trufflehog
                kubeconform
                kube-linter
                fd
                kustomize
                git
              ];
              src = ../../.;
            }
            ''
              cp -r $src ./src
              chmod +w -R ./src
              mkdir -p ./src/.json-schema/
              ln -s ${inputs.json-schema-kube-catalog} ./src/.json-schema/kube
              # cp -r ${inputs.json-schema-crds-catalog} ./src/.json-schema/crds-catalog
              ln -s ${inputs.json-schema-crds-catalog} ./src/.json-schema/crds-catalog
              cd ./src
              task lint --verbose --output prefixed
              cd ..
              ln -sf ./src $out
            '';
      };
    };
}
