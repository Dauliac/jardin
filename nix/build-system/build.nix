# SPDX-License-Identifier: AGPL-3.0-or-later
{ ... }: {
  imports = [ ./compile.nix ];
  perSystem =
    { system
    , inputs'
    , config
    , ...
    }:
    let
      inherit (config) artifact;
    in
    {
      packages.default = artifact;
      packages.jardin = artifact;
    };
}
