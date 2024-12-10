{
  config,
  pkgs,
  ...
}: {
    environment.systemPackages = with pkgs; [
        kubectl
        k3s
        helm
        kumactl
        flux
    ];
   networking.firewall.allowedTCPPorts = [
     config.services.kubernetes.apiserver.securePort
   ];
   services.k3s = {
     enable = true;
     role = "server";
   };
}
