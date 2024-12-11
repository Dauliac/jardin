{
  config,
  lib,
  moduleWithSystem,
  withSystem,
  inputs,
  ...
}: {
  config = {
    flake = {
      nixosModules.jardin = moduleWithSystem (
        {config}: nixos: {
          imports = [
            {
              nixpkgs.overlays = lib.mkForce [
                inputs.nix-snapshotter.overlays.default
                inputs.sops-nix.overlays.default
                inputs.comin.overlays.default
              ];
            }
            inputs.comin.nixosModules.comin
            inputs.nix-snapshotter.nixosModules.default
            inputs.sops-nix.nixosModules.default
            ./configuration.nix
          ];
        }
      );
      nixosModules.default = config.flake.nixOsModules.jardin;
      nixosConfigurations.jardin = withSystem "x86_64-linux" (ctx @ {
        config,
        inputs',
        lib,
        ...
      }:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            ({
              config,
              lib,
              packages,
              pkgs,
              ...
            }: {
              imports = [
                ctx.config.flake.nixosModules.jardin
                {
                  networking.hostName = "jardin";
                }
              ];
            })
          ];
        });
    };
  };
}
