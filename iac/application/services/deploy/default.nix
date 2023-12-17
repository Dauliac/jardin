{ pkgs, config }:
let
  configService = import ../config/default.nix { inherit pkgs; };
  configFile = { cluster, configService }: configService.write config;
  tasks = import ./tasks/default.nix config.cluster;
  json = pkgs.writeText "deploy.json" (builtins.toJSON tasks);
in
{ deploy = { cluster }: ({ inherit tasks; }); }
