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
                inputs.comin.overlays.comin
              ];
            }
            inputs.comin.nixosModules.comin
            inputs.nix-snapshotter.nixosModules.default
            inputs.sops-nix.nixosModules.default
            inputs.home-manager.nixosModules.default
            ./configuration.nix
            {
              home-manager = {
                sharedModules = [
                  ./graphical/home-manager
                ];
                extraSpecialArgs = {inherit inputs;};
                users.jardin = ./graphical/home-manager/home.nix;
              };
            }
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
