{
  pkgs,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    kubernetes-helm
    kumactl
    flux
  ];
  services.rke2 = {
    enable = true;
  };
  systemd.services.emplace-rke-manifests =
    let
      rkeManifestsDir = "${config.services.rke2.dataDir}/server/manifests";
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
      before = [ "rke2-server.service" ]; # Exécute avant RKE2
      wantedBy = [ "multi-user.target" ]; # Démarrage automatique au boot
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${script}";
      };
    };
}
