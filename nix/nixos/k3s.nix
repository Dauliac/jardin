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
        target = "gitrepo.yaml";
        source = ../../kube/gitrepo.yaml;
      };
    };
  };
}
