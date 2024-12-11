{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kubectl
    k3s
    kubernetes-helm
    kumactl
    flux
  ];
  networking.firewall.allowedTCPPorts = [
    config.services.kubernetes.apiserver.securePort
  ];
  services.k3s = {
    enable = true;
    role = "server";
    manifests = {
      fluxcd = {
        target = "fluxcd.yaml";
        content = {
          apiVersion = "helm.cattle.io/v1";
          kind = "HelmChart";
          metadata = {
            namespace = "kube-system";
            name = "flux2";
          };
          spec = {
            targetNamespace = "flux-system";
            createNamespace = true;
            version = "2.14.0";
            chart = "flux2";
            repo = "https://fluxcd-community.github.io/helm-charts";
          };
        };
      };
      gitrepo = {
        target = "jardin.gitrepository.yaml";
        source = ../../kube/base/jardin.gitrepository.yaml;
      };
      base = {
        target = "base.kustomization.yaml";
        source = ../../kube/base/base.kustomization.yaml;
      };
      controllers = {
        target = "controllers.kustomization.yaml";
        source = ../../kube/base/controllers.kustomization.yaml;
      };
      application = {
        target = "applications.kustomization.yaml";
        source = ../../kube/base/applications.kustomization.yaml;
      };
    };
  };
}
