{ lib, pkgs, inputs, system, cluster, }:
let binName = import ./bin-name.nix { };
in
{
  dns =
    let
      modelService = import ../../../../../domain/models/networks/dns;
      serviceLib =
        import ../../../../../infrastructure/services/back/dns/cloudflare.nix {
          inherit lib pkgs inputs system;
        };
      model = modelService.configure {
        inherit (cluster) targets;
        inherit (cluster) domain;
      };
      service = serviceLib.configure { inherit model; };
    in
    rec {
      name = binName.mkBinName { name = "dns"; };
      job = service.mkJob { inherit name; };
    };
}
