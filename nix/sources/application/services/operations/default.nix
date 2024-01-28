{ lib
, pkgs
, inputs
, system
,
}:
let
  configService = import ../../config { inherit lib pkgs; };
  # TODO: integrate this as curry before deploy
  # configFile = { cluster, configService, }: configService.write config;
in
{
  deploy = { config }: (import ./deploy/tasks { inherit lib pkgs inputs system config; });
}
