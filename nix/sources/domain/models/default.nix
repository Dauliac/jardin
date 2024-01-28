_:
let
  networks = import ./networks;
  storages = import ./storages;
in
{
  # NOTE: This is our aggregate.
  cluster = {
    configure = { config }: {
      networks = networks.configure { inherit config; };
      storages = storages.configure { inherit (config) nodes; };
      inherit config;
    };
  };
}
