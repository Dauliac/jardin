{ lib
, pkgs
, inputs
, system
,
}: {
  configure =
    { clusterModel
    , diskoService
    , nameServerService
    ,
    }:
    let
      mkNixOs = { name }: {
        nix.settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
        };
        nixpkgs = { overlays = [ self.overlays.pkgs ]; };
        virtualisation = {
          podman = {
            enable = true;
            # NOTE: Create a `docker` alias for podman, to use it as a drop-in replacement
            dockerCompat = true;
            # NOTE: Required for containers under podman-compose to be able to talk to each other.
            defaultNetwork.settings.dns_enabled = true;
          };
          oci-containers.backend = "podman";
        };
        # NOTE: Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
        zramSwap.enable = true;
        networking = {
          hostname = name;
          nameservers = nameServerService.mkNameservers;
        };

        # TODO: edit this in function of services mkSystemPackages
        environment.systemPackages = with pkgs; [ htop ];
      };
    in
    {
      mkNixOsInstances =
        lib.mapAttrs
          (name: value:
            let
              commonNixOsConfiguration = mkNixOs { inherit name; };
            in
            { } // commonNixOsConfiguration)
          clusterModel.nodes;
    };
}
