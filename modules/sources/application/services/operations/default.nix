{ lib, pkgs, inputs, system }:
let
  configService = import ../../config { inherit lib pkgs; };
  # TODO: integrate this as curry before deploy
  # configFile = { cluster, configService, }: configService.write config;
in
{
  deploy = { cluster }:
    (import ./deploy/tasks/default.nix {
      inherit lib pkgs inputs system cluster;
    });
}
