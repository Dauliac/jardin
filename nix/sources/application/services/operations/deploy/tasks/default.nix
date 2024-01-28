{ lib
, pkgs
, inputs
, system
, config
,
}:
let
  binName = import ./bin-name.nix { };
  clusterService = import ../../../../../domain/models/default.nix { };
  cluster = clusterService.configure { inherit config; };
in
{
  dns =
    let
      cloudflare = import ../../../../../infrastructure/services/back/cloudflare-dns.nix {
        inherit lib pkgs inputs system;
      };
      service = cloudflare.configure { model = cluster.networks.dns; };
    in
    rec {
      name = binName.mkBinName { name = "dns"; };
      job = service.mkJob { inherit name; };
    };
  deploy =
    let
      disko = import ../../../../../infrastructure/services/back/disko {
        inherit lib pkgs inputs system;
      };
      diskoService = disko.configure { model = cluster.storage.disks; };
      nameServer = import ../../../../../infrastructure/services/back/name-server.nix {
        inherit lib pkgs inputs system;
      };
      nameServerService = nameServer.configure {
        nameServerModel = cluster.networks.dns.mkPrivacyFriendlyNameservers;
      };
      nixOs = import ../../../../../infrastructure/services/back/nixos.nix {
        inherit lib pkgs inputs system;
      };
      nixOsService = nixOs.configure {
        clusterModel = cluster;
        inherit diskoService nameServerService;
      };
    in
    rec { name = binName.mkBinName { name = "dns"; }; };
}
