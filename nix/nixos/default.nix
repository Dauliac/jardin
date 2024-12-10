{inputs, ...}: {
  config = {
    flake.nixosConfigurations.les-chiens = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.comin.nixosModules.comin
        inputs.nix-snapshotter.nixosModules.default
        ./configuration.nix
        {
          nixpkgs.overlays = [ inputs.nix-snapshotter.overlays.default ];
        }
      ];
    };
  };
}
