# SPDX-License-Identifier: AGPL-3.0-or-later
{ ... }: {
  imports = [ ./compile.nix ./docs.nix ];
  perSystem =
    { system
    , inputs'
    , config
    , pkgs
    , ...
    }:
    let
      inherit (config) artifact;
      inherit (config) docsPackages;
    in
    {
      packages.default = artifact;
      packages.jardin = artifact;
    };
}
