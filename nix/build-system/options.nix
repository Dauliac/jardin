{
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mdDoc mkOption;
in
{
  options = {
    nixpkgsConfig = mkOption {
      description = mdDoc "NixPkgs config to import";
      default = {
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
        overlays = with inputs; [
          nix-snapshotter.overlays.default
          sops-nix.overlays.default
          comin.overlays.default
          nur.overlays.default
        ];
      };
    };
  };
}
