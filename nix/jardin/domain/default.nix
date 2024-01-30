{ flake-parts-lib
, config
, pkgs
, inputs
, ...
}: {
  flake = {
    lib.domain.cluster =
      let
        networks = import ./networks;
        storages = import ./storages;
      in
      {
        configure = { config }: {
          networks = networks.configure { inherit config; };
          storages = storages.configure { inherit (config) nodes; };
          inherit config;
        };
      };
  };
  config.flake = { };
}
