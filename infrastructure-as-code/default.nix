{
  inputs,
  self,
  ...
}: {
  imports = [./app ./infra ./domain];
  config = {
    perSystem = {
      lib,
      pkgs,
      system,
      ...
    }: {
      _module.args.pkgs = import self.inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.nix-snapshotter.overlays.default
        ];
        config.allowUnfree = true;
      };
    };
  };
}
