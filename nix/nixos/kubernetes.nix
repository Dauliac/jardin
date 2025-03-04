{
  pkgs,
  config,
  ...
}:
let
  rkeManifestsDir = "${config.services.rke2.dataDir}/server/manifests";
in
{
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    kubernetes-helm
    kumactl
    fluxcd
  ];
  services.rke2 = {
    enable = true;
    extraFlags = [
      "--enable-servicelb"
    ];
  };
  systemd.services.emplace-rke-manifests =
    let
      script = pkgs.writers.writeBash "emplace-rke-manifests" ''
        set -o errexit
        set -o pipefail
        set -o nounset

        main() {
          mkdir -p ${rkeManifestsDir}
          cp -f ${../../kube/base/fluxcd.helmchart.cattle.yaml} ${rkeManifestsDir}/fluxcd.helmchart.cattle.yaml
        }
        main
      '';
    in
    {
      description = "Ensure RKE2 manifests are in place before RKE2 starts";
      before = [ "rke2-server.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = script;
      };
    };
  systemd.services.emplace-kubeconfig =
    let
      kubeConfigSrc = "/etc/rancher/rke2/rke2.yaml";
      kubeConfigDirDst = "/home/admin/.kube";
      kubeConfigDst = "${kubeConfigDirDst}/config";
      script = pkgs.writers.writeBash "emplace-kubeconfig" ''
        set -o errexit
        set -o pipefail
        set -o nounset
        set -x

        main() {
          mkdir -p ${kubeConfigDirDst}
          cp -f ${kubeConfigSrc} ${kubeConfigDst}
          chown -R admin:admin ${kubeConfigDirDst}
          chmod 400 ${kubeConfigDst}
        }
        main
      '';
    in
    {
      description = "Copy RKE2 kubeconfig ${kubeConfigSrc} to ${kubeConfigDst}";
      after = [
        "network.target"
      ];
      wants = [ "rke2-server.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = script;
        Restart = "on-failure";
        RestartSec = 5;
        StartLimitBurst = 50;
        StartLimitIntervalSec = 600;
      };
    };
  systemd.services.emplace-sops-secret =
    let
      sopsKeyFile = config.sops.age.keyFile;
      outputFile="${rkeManifestsDir}/sops-age.secret.yaml";
      script = pkgs.writers.writeBash "emplace-sops-secret" ''
        set -o errexit
        set -o pipefail
        set -o nounset

        main() {
          mkdir -p ${rkeManifestsDir}

          if [[ ! -f "${sopsKeyFile}" ]]; then
            echo "ERROR: SOPS key file not found at ${sopsKeyFile}"
            exit 1
          fi
          SOPS_KEY=$(cat "${sopsKeyFile}")

          echo "Generating Kubernetes Secret YAML for SOPS..."
            ${pkgs.kubectl}/bin/kubectl create secret generic sops-age -n flux-system \
            --from-literal=sops-key="$SOPS_KEY" \
            --dry-run=client -o yaml > ${outputFile}

          echo "SOPS Secret successfully created at ${outputFile}"
        }

        main
      '';
    in
    {
      description = "Generate SOPS secret for RKE2 manifests";
      before = [ "rke2-server.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${script}";
      };
    };
}
