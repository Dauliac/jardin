{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.jardin;
in {
  config =
    mkIf
    cfg.enable
    {
      virtualisation.containerd = {
        enable = true;
        nixSnapshotterIntegration = true;
      };
      services.nix-snapshotter = {
        enable = true;
      };
      environment.systemPackages = with pkgs; [nerdctl];
    };
}
