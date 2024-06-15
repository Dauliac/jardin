{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
  cfg = config.jardin;
in {
  config =
    mkIf
    cfg.enable
    {
      environment.systemPackages = with pkgs; [
        kubectl
        k3s
        helm
        kumactl
      ];
      networking.firewall.allowedTCPPorts = [
        config.services.kubernetes.apiserver.securePort
      ];
      services.k3s = {
        enable = true;
        role = "server";
        # TODO: should we add this flag ?
        extraFlags = mkForce (toString [
          # TODO: enable this when option is stable: https://docs.k3s.io/cli/secrets-encrypt?_highlight=secrets&_highlight=encryption
          # "--secrets-encryption"
          "--disable=traefik"
          # TODO: find way to merge this with nix-snapshotter configs
          "--snapshotter overlayfs"
        ]);
      };
    };
}
