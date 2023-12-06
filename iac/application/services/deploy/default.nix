{ pkgs, jardin }:
let
  configService = import ../config/default.nix { inherit pkgs; };
  config = { cluster, configService }: configService.write cluster;
  model = import ./model.nix;
in
{
  deploy = { };
}
