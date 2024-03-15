# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption mdDoc types;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in {
  options.perSystem = mkPerSystemOption ({pkgs, ...}: {
    options = {
      formatterPackages = mkOption {
        description = mdDoc "Packages used to format the repo";
        default = with pkgs; [nixpkgs-fmt alejandra statix];
      };
    };
  });
  config.perSystem = {
    config,
    pkgs,
    ...
  }: {
    formatter = pkgs.writeShellApplication {
      name = "normalise-nix";
      runtimeInputs = config.formatterPackages;
      text = ''
        set -o xtrace
        ${pkgs.alejandra}/bin/alejandra "$@"
        ${pkgs.statix}/bin/statix fix "$@"
      '';
    };
  };
}
