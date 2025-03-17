{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mdDoc mkOption;
  rkeManifestsDir = "${config.services.rke2.dataDir}/server/manifests";
  cfg = config.jardin;
in
{
  options = {
    jardin = {
      publicNetworkInterface = mkOption {
        default = "eth0";
      };
    };
  };
  config = {
    jardin.publicNetworkInterface = "wlp0s20f3";
    environment.systemPackages = with pkgs; [
      kubectl
      k9s
      kubernetes-helm
      kumactl
      fluxcd
      kustomize
    ];
    services.rke2 = {
      enable = true;
      extraFlags = [
        "--ingress-controller=none"
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
        outputFile = "${rkeManifestsDir}/sops-age.secret.yaml";
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
            cat "${sopsKeyFile}" \
            | ${pkgs.kubectl}/bin/kubectl  create secret generic sops-age \
            --namespace=flux-system \
            --dry-run=client \
            -o yaml \
            --from-file=age.agekey=/dev/stdin > ${outputFile}

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
    systemd.services.emplace-rke-cluster-manifests =
      let
        script = pkgs.writers.writeBash "emplace-rke-manifests" ''
          set -o errexit
          set -o pipefail
          set -o nounset


          main() {
            mkdir -p ${rkeManifestsDir}
            declare -rgx DOMAIN=$(cat ${config.sops.secrets.domain.path})
            declare -rgx IP_ADDRESS=$(${pkgs.iproute2}/bin/ip -4 addr show ${config.jardin.publicNetworkInterface} | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
            if [[ -z $IP_ADDRESS ]]; then
              printf "Failed to get ip adress of interface ${config.jardin.publicNetworkInterface}\n"
              exit 1
            fi
            if [[ -z $DOMAIN ]]; then
              printf "Failed to get domain from file ${config.sops.secrets.domain.path}\n"
              exit 1
            fi

            ${pkgs.kubectl}/bin/kubectl create secret generic cluster-config \
              --namespace=flux-system \
              --from-literal=DOMAIN="$DOMAIN" \
              --from-literal=IP_ADDRESS="$IP_ADDRESS" \
              --dry-run=client -o yaml > ${rkeManifestsDir}/cluster.secret.yaml
          }
          main
        '';
      in
      {
        description = "Ensure RKE2 cluster specific manifests are in place before RKE2 starts";
        before = [ "rke2-server.service" ];
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = script;
          Restart = "on-failure";
          RestartSec = 5;
          StartLimitBurst = 50;
          StartLimitIntervalSec = 600;
        };
      };
  };
}
