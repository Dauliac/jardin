{ lib
, config
, pkgs
, inputs
, system
, ...
}:
let
  cfg = config.flake.nixCluster;
in
{
  flake = {
    lib.jardin.deploy =
      Mkif (cfg.nixCluster != { }) { mkTasks = { pkgs }: { dns = { }; }; };
  };
  perSystem = { pkgs, ... }: {
    apps.jardin.tasks.deploy = lib.jardin.deploy.mkTasks { inherit pkgs; };
  };
}
# { lib
# , pkgs
# , inputs
# , system
# , config
# ,
# }:
# let
#   clusterService = import ../../../domain/models/default.nix;
#   # TODO: build this file with jardin rust and nix ast
#   # TODO: find way to import this without arguments
#   mkBinName = { name }:
#     let
#       prefix = "deploy";
#       separator = "-";
#     in
#     "${prefix}${separator}${name}";
#   cluster = clusterService.configure { inherit config; };
# in
# {
#   dns =
#     let
#       cloudflare = import ../../../infrastructure/back/cloudflare-dns.nix {
#         inherit lib pkgs inputs system;
#       };
#       service = cloudflare.configure { model = cluster.networks.dns; };
#     in
#     rec {
#       name = mkBinName { name = "dns"; };
#       job = service.mkJob { inherit name; };
#     };
#   deploy =
#     let
#       disko = import ../../../infrastructure/back/disko {
#         inherit lib pkgs inputs system;
#       };
#       diskoService = disko.configure { model = cluster.storage.disks; };
#       nameServer = import ../../../infrastructure/back/name-server.nix {
#         inherit lib pkgs inputs system;
#       };
#       nameServerService = nameServer.configure {
#         nameServerModel = cluster.networks.dns.mkPrivacyFriendlyNameservers;
#       };
#       nixOs = import ../../../infrastructure/back/nixos.nix {
#         inherit lib pkgs inputs system;
#       };
#       nixOsService = nixOs.configure {
#         clusterModel = cluster;
#         inherit diskoService nameServerService;
#       };
#     in
#     rec { name = mkBinName { name = "dns"; }; };
# }

