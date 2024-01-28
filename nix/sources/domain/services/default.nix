_:
let
  models = import ../models/default.nix;
in
{
  deploy = {
    bootstraps = cluster: {
      nixify = { implementation }: implementation models.bootstraps cluster;
    };
    networks = cluster: {
      dns = { implementation }: implementation models.networks.dns cluster;
      backbone = { implementation }: implementation models.networks.backbone cluster;
    };
    platforms = cluster: {
      kubernetes = { implementation }: implementation models.platforms.kubernetes cluster;
      nomad = { implementation }: implementation models.platforms.nomad cluster;
    };
    applications = cluster: { };
  };
}
