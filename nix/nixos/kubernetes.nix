{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  rkeManifestsDir = "${config.services.rke2.dataDir}/server/manifests";
  kubeConfig = "/etc/rancher/rke2/rke2.yaml";
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
    virtualisation.containerd.enable = true;
    jardin.publicNetworkInterface = "wlp0s20f3";
    environment.systemPackages = with pkgs; [
      kubectl
      k9s
      jq
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
    systemd.services.emplace-kubeconfig =
      let
        kubeConfigDirDst = "/home/admin/.kube";
        kubeConfigDst = "${kubeConfigDirDst}/config";
        script = pkgs.writers.writeBash "emplace-kubeconfig" ''
          set -o errexit
          set -o pipefail
          set -o nounset
          set -x

          main() {
            mkdir -p ${kubeConfigDirDst}
            cp -f ${kubeConfig} ${kubeConfigDst}
            chown -R admin:admin ${kubeConfigDirDst}
            chmod 400 ${kubeConfigDst}
          }
          main
        '';
      in
      {
        description = "Copy RKE2 kubeconfig ${kubeConfig} to ${kubeConfigDst}";
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
    systemd.services.emplace-rke-containerd-config =
      let
        # https://docs.rke2.io/advanced#configuring-containerd
        script = pkgs.writers.writeBash "generate-nvidia-containerd-config" ''
          cat <<EOF > ${config.services.rke2.dataDir}/agent/etc/containerd/config.toml.tmpl
          version = 2

          [plugins."io.containerd.internal.v1.opt"]
            path = "/var/lib/rancher/rke2/agent/containerd"
          [plugins."io.containerd.grpc.v1.cri"]
            stream_server_address = "127.0.0.1"
            stream_server_port = "10010"
            enable_selinux = false
            enable_unprivileged_ports = true
            enable_unprivileged_icmp = true
            sandbox_image = "index.docker.io/rancher/mirrored-pause:3.6"

          [plugins."io.containerd.grpc.v1.cri".containerd]
            snapshotter = "overlayfs"
            disable_snapshot_annotations = true
            default_runtime_name = "nvidia"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
            runtime_type = "io.containerd.runc.v2"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true

          [plugins."io.containerd.grpc.v1.cri".registry]
            config_path = "/var/lib/rancher/rke2/agent/etc/containerd/certs.d"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
            privileged_without_host_devices = false
            runtime_engine = ""
            runtime_root = ""
            runtime_type = "io.containerd.runc.v2"

            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
              BinaryName = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime"
              SystemdCgroup = true
          EOF
        '';
      in
      {
        description = "Generate Nvidia containerd config";
        before = [ "rke2-server.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${script}";
        };
      };

    systemd.services.emplace-rke-sops-secret =
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
        inherit (config.networking.interfaces.wlp0s20f3.ipv4) addresses;
        firstIp = (builtins.head addresses).address;
        script = pkgs.writers.writeBash "emplace-rke-manifests" ''
          set -o errexit
          set -o pipefail
          set -o nounset

          main() {
            mkdir -p ${rkeManifestsDir}
            declare -rgx DOMAIN=$(cat ${config.sops.secrets.domain.path})
            declare -rgx LETS_ENCRYPT_EMAIL=$(cat ${config.sops.secrets.lets_encrypt_email.path})
            declare -rgx LETS_ENCRYPT_SERVER=$(cat ${config.sops.secrets.lets_encrypt_server.path})
            declare -rgx IP_ADDRESS=${firstIp}
            if [[ -z $IP_ADDRESS ]]; then
              printf "Failed to get main ip adress of interface\n"
              exit 1
            fi
            if [[ -z $DOMAIN ]]; then
              printf "Failed to get domain from file ${config.sops.secrets.domain.path}\n"
              exit 1
            fi
            if [[ -z $LETS_ENCRYPT_EMAIL ]]; then
              printf "Failed to get let's encrypt email from file ${config.sops.secrets.lets_encrypt_email.path}\n"
              exit 1
            fi
            if [[ -z $LETS_ENCRYPT_SERVER ]]; then
              printf "Failed to get let's encrypt server from file ${config.sops.secrets.lets_encrypt_server.path}\n"
              exit 1
            fi

            ${pkgs.kubectl}/bin/kubectl create secret generic cluster-config \
              --namespace=flux-system \
              --from-literal=DOMAIN="$DOMAIN" \
              --from-literal=IP_ADDRESS="$IP_ADDRESS" \
              --from-literal=LETS_ENCRYPT_EMAIL="$LETS_ENCRYPT_EMAIL" \
              --from-literal=LETS_ENCRYPT_SERVER="$LETS_ENCRYPT_SERVER" \
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
    systemd.services.apply-rke2-manifests =
      let
        script = pkgs.writers.writeBash "apply-rke2-manifests" ''
          set -o errexit
          set -o pipefail
          set -o nounset

          main() {
            echo "Applying RKE2 cluster manifests..."
            ${pkgs.kubectl}/bin/kubectl apply -f ${../../kube/base/fluxcd.helmchart.cattle.yaml}
            ${pkgs.kubectl}/bin/kubectl apply -f ${rkeManifestsDir}/cluster.secret.yaml
            ${pkgs.kubectl}/bin/kubectl apply -f ${rkeManifestsDir}/sops-age.secret.yaml

            local max_retries=30
            local sleep_time=10
            local attempt=0
            until ( \
              ${pkgs.kubectl}/bin/kubectl apply -f ${../../kube/base/jardin.gitrepository.yaml} \
              && ${pkgs.kubectl}/bin/kubectl apply -f ${../../kube/base/jardin.kustomization.yaml} \
            ); do
              attempt=$((attempt + 1))
              echo "Attempt $attempt failed, retrying in $sleep_time seconds..."
              if [[ $attempt -ge $max_retries ]]; then
                echo "Max retries reached, exiting with failure."
                exit 1
              fi
              sleep $sleep_time
            done
            echo "Manifests applied successfully"
          }

          main
        '';
      in
      {
        description = "Apply Kubernetes manifests after RKE2 starts";
        after = [
          "rke2-server.service"
          "network.target"
        ];
        wants = [ "rke2-server.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Environment = "KUBECONFIG=${kubeConfig}";
          ExecStart = script;
          Restart = "on-failure";
          RestartSec = 10;
          StartLimitBurst = 100;
          StartLimitIntervalSec = 600;
        };
      };
  };
}
